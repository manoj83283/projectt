#!/usr/bin/env python3
"""Recursive HEIC/HEIF to JPG/PNG converter with safe ZIP streaming."""
from __future__ import annotations
import argparse,csv,datetime as dt,hashlib,io,json,logging,os,re,shutil,signal,subprocess,sys,threading,time,uuid,zipfile
from dataclasses import asdict,dataclass
from pathlib import Path,PurePosixPath
from typing import Optional
try:
    from PIL import Image,ImageOps,UnidentifiedImageError
except ImportError as e:
    print(f"Pillow is required: {e}. Run run_heic_converter.bat",file=sys.stderr); raise SystemExit(2)
try:
    import pillow_heif
    pillow_heif.register_heif_opener()
except ImportError:
    pillow_heif=None
try: import piexif
except ImportError: piexif=None

VERSION="1.0.0"; CHUNK=8*1024*1024; CONFIRM="DELETE-HEIC-AFTER-VERIFIED-CONVERSION"; STOP=threading.Event()
TEMP_RE=re.compile(r"^\..+\.[0-9a-f]{32}\.heicconv\.part$")
INVALID_COMPONENT=re.compile(r'[<>:"/\\|?*\x00-\x1f]')
HEIC_EXT={'.heic','.heif'}
def now(): return dt.datetime.now(dt.timezone.utc).astimezone().isoformat(timespec='seconds')
def human(n):
    x=float(max(0,n))
    for u in ('B','KiB','MiB','GiB','TiB'):
        if x<1024 or u=='TiB': return f'{x:.2f} {u}'
        x/=1024
def duration(s):
    s=max(0,int(s)); h,r=divmod(s,3600);m,s=divmod(r,60);return f'{h:02d}:{m:02d}:{s:02d}' if h else f'{m:02d}:{s:02d}'
def sig_handler(sig,_): STOP.set();logging.warning('Interruption requested (signal %s)',sig)
def norm(s): return Path(os.path.expandvars(os.path.expanduser(s.strip().strip('"')))).resolve()
def within(c,p):
    try:c.resolve().relative_to(p.resolve());return True
    except ValueError:return False

@dataclass
class Row:
    source:str; source_kind:str; member_name:str=""; output:str=""; format:str=""; quality:int=0; source_size:int=0; output_size:int=0; width:int=0; height:int=0; source_sha256:str=""; output_sha256:str=""; exif_preserved:bool=False; orientation_applied:bool=False; icc_preserved:bool=False; status:str="PLANNED"; source_deleted:bool=False; archive_deleted:bool=False; error:str=""
@dataclass
class Summary:
    version:str=VERSION;run_id:str="";started_at:str="";finished_at:str="";ordinary_found:int=0;zip_archives_found:int=0;zip_members_found:int=0;converted:int=0;corrupted_routed:int=0;conflicts:int=0;failed:int=0;originals_deleted:int=0;originals_preserved:int=0;archives_deleted:int=0;archives_preserved:int=0;source_bytes:int=0;output_bytes:int=0;elapsed_seconds:float=0.0;interrupted:bool=False;dry_run:bool=False;delete_originals:bool=False;capacity_required:int=0;capacity_free:int=0;capacity_sufficient:bool=False

class Progress:
    def __init__(self,mins):
        self.start=time.monotonic();self.stage='STARTING';self.current='';self.total_items=0;self.done=0;self.total_work=0;self.read=0;self.written=0;self.last=0;self.interval=mins*60;self.next=self.interval;self.stop=threading.Event();self.lock=threading.Lock();self.thread=threading.Thread(target=self._beat,daemon=True);self.thread.start()
    def text(self):
        e=max(.001,time.monotonic()-self.start);rate=self.read/e;eta='n/a'
        if self.total_work and self.read<self.total_work and rate:eta=duration((self.total_work-self.read)/rate)
        return f"stage={self.stage} | current={self.current or '-'} | processed={self.done}/{self.total_items or '?'} | read={human(self.read)} | output={human(self.written)} | rate={human(int(rate))}/s | elapsed={duration(e)} | ETA={eta}"
    def emit(self,force=False,log=False):
        t=time.monotonic()
        with self.lock:
            text=self.text()
            if force or t-self.last>=1:print('\r'+text[:250].ljust(250),end='',flush=True);self.last=t
            if log:logging.info('PROGRESS %s',text)
    def set(self,s,c=''):self.stage=s;self.current=c;self.emit(True,True)
    def add(self,n):self.read+=n;self.emit()
    def complete(self,n=0):self.done+=1;self.written+=n;self.emit(True,True)
    def fail(self):self.done+=1;self.emit(True,True)
    def _beat(self):
        while not self.stop.wait(5):
            e=time.monotonic()-self.start
            if e>=self.next:
                x=self.text();logging.info('HEARTBEAT %s',x);print('\nHEARTBEAT: '+x,flush=True);self.next+=self.interval
    def close(self):self.stop.set();self.thread.join(2);self.emit(True,True);print()

def hash_file(path,progress=None,label=''):
    h=hashlib.sha256()
    with path.open('rb',buffering=0) as f:
        while True:
            if STOP.is_set():raise InterruptedError('Interrupted while hashing')
            b=f.read(CHUNK)
            if not b:break
            h.update(b)
            if progress:progress.add(len(b));progress.current=label or str(path)
    return h.hexdigest()
def nearest(p):
    while not p.exists() and p!=p.parent:p=p.parent
    return p
def ensure_space(p,need,reserve):
    free=shutil.disk_usage(nearest(p)).free
    if free<need+reserve:raise OSError(f'Insufficient output space: need {human(need+reserve)}, free {human(free)}')
def fsync_dir(p):
    if os.name=='nt':return
    try:fd=os.open(p,os.O_RDONLY);os.fsync(fd);os.close(fd)
    except OSError:pass
def cleanup(root):
    n=0
    if not root.exists():return n
    for cur,_,files in os.walk(root):
        for name in files:
            if TEMP_RE.match(name):
                p=Path(cur)/name
                try:p.unlink();n+=1;logging.warning('Removed stale converter part: %s',p)
                except OSError as e:logging.warning('Could not remove stale part %s: %s',p,e)
    return n

def open_decoded(path):
    """Decode with Pillow/pillow-heif; use local ImageMagick only as fallback."""
    try:
        with Image.open(path) as im:im.load();return im.copy(),False
    except Exception as first:
        magick=shutil.which('magick')
        if not magick:raise first
        result=subprocess.run([magick,str(path),'-auto-orient','png:-'],capture_output=True,timeout=300,check=False)
        if result.returncode or not result.stdout:raise IOError((result.stderr or b'ImageMagick HEIC decode failed').decode(errors='replace')[-500:])
        with Image.open(io.BytesIO(result.stdout)) as im:im.load();return im.copy(),True

def validate_heic(path):
    image,_=open_decoded(path);return image.size

def prepare_image(path):
    src,fallback_oriented=open_decoded(path);original_size=src.size;exif=src.getexif();orientation=int(exif.get(274,1) or 1);icc=src.info.get('icc_profile');converted=src if fallback_oriented else ImageOps.exif_transpose(src)
    converted.load();exif_out=converted.getexif()
    if exif_out is not None:exif_out[274]=1
    return converted.copy(),exif_out,icc,fallback_oriented or orientation not in (0,1),original_size

def validate_output(path,fmt,expected):
    with Image.open(path) as im:
        if im.format.upper()!=fmt:raise IOError(f'Generated format is {im.format}, expected {fmt}')
        im.verify()
    with Image.open(path) as im:
        im.load()
        if im.size!=expected:raise IOError(f'Generated dimensions {im.size} != expected {expected}')

def convert_one(source,target,fmt,quality,reserve,progress):
    progress.set('VALIDATE_SOURCE',str(source));validate_heic(source); source_hash=hash_file(source,progress,str(source)); image,exif,icc,oriented,_=prepare_image(source); target.parent.mkdir(parents=True,exist_ok=True)
    if target.exists():raise FileExistsError(f'Output conflict; refusing to overwrite: {target}')
    estimate=max(source.stat().st_size,image.width*image.height*4);ensure_space(target.parent,estimate,reserve)
    part=target.parent/f'.{target.name}.{uuid.uuid4().hex}.heicconv.part'
    try:
        progress.set('ENCODE_PART',str(target));kwargs={}
        exif_bytes=exif.tobytes() if exif and len(exif) else None
        if exif_bytes:kwargs['exif']=exif_bytes
        if icc:kwargs['icc_profile']=icc
        if fmt=='JPEG':
            if image.mode not in ('RGB','L'):image=image.convert('RGB')
            kwargs.update(quality=quality,optimize=True,subsampling='4:2:0')
        image.save(part,format=fmt,**kwargs)
        with part.open('rb+') as f:f.flush();os.fsync(f.fileno())
        validate_output(part,fmt,image.size);part_hash=hash_file(part,progress,str(part));os.replace(part,target);fsync_dir(target.parent);final_hash=hash_file(target,progress,str(target))
        if final_hash!=part_hash:raise IOError('Final output SHA-256 mismatch')
        validate_output(target,fmt,image.size)
        return source_hash,final_hash,target.stat().st_size,image.size,bool(exif_bytes),oriented,bool(icc)
    except BaseException:
        try:part.unlink(missing_ok=True)
        except OSError:pass
        raise

def verified_copy_raw(source,target,reserve,progress):
    target.parent.mkdir(parents=True,exist_ok=True)
    if target.exists():raise FileExistsError(f'Corrupted-route conflict: {target}')
    ensure_space(target.parent,source.stat().st_size,reserve);part=target.parent/f'.{target.name}.{uuid.uuid4().hex}.heicconv.part';h=hashlib.sha256();written=0
    try:
        with source.open('rb',buffering=0) as s,part.open('xb',buffering=0) as d:
            while True:
                if STOP.is_set():raise InterruptedError('Interrupted while routing corrupt source')
                b=s.read(CHUNK)
                if not b:break
                d.write(b);h.update(b);written+=len(b);progress.add(len(b))
            d.flush();os.fsync(d.fileno())
        digest=h.hexdigest()
        if hash_file(part,progress,str(part))!=digest:raise IOError('Corrupted-route part hash mismatch')
        os.replace(part,target);fsync_dir(target.parent)
        if hash_file(target,progress,str(target))!=digest:raise IOError('Corrupted-route final hash mismatch')
        return digest,written
    except BaseException:
        try:part.unlink(missing_ok=True)
        except OSError:pass
        raise

def scan(source,progress):
    ordinary=[];archives=[]
    for cur,dirs,files in os.walk(source,followlinks=False):
        p=Path(cur);progress.set('DIRECTORY_SCAN',str(p));dirs[:]=sorted(d for d in dirs if not (p/d).is_symlink())
        for name in sorted(files):
            q=p/name
            if q.is_symlink() or not q.is_file():continue
            if q.suffix.lower() in HEIC_EXT:ordinary.append(q)
            elif q.suffix.lower()=='.zip':
                members=[];err=''
                try:
                    with zipfile.ZipFile(q) as z:
                        all_regular=[m for m in z.infolist() if not m.is_dir()]
                        members=[m for m in all_regular if PurePosixPath(m.filename).suffix.lower() in HEIC_EXT]
                except Exception as e:all_regular=[];err=f'{type(e).__name__}: {e}'
                archives.append((q,members,all_regular,err))
    return ordinary,archives

def safe_zip_parts(name):
    parts=[]
    for raw in PurePosixPath(name.replace('\\','/')).parts:
        if raw in ('','/','.', '..'):continue
        clean=INVALID_COMPONENT.sub('_',raw).strip().rstrip('. ')
        if clean:parts.append(clean[:180])
    return parts or ['unnamed_member']

def zip_member_target(output,source_root,archive,member,ext):
    archive_rel=archive.relative_to(source_root);base=output/archive_rel.parent/(archive_rel.stem+'__ZIP')
    safe_parts=safe_zip_parts(member.filename)
    rel=Path(*safe_parts);return (base/rel).with_suffix(ext)
def zip_corrupt_target(corrupt,source_root,archive,member):
    archive_rel=archive.relative_to(source_root);safe=safe_zip_parts(member.filename)
    return corrupt/archive_rel.parent/(archive_rel.stem+'__ZIP')/Path(*safe)

def stream_member(z,member,temp_root,reserve,progress):
    temp_root.mkdir(parents=True,exist_ok=True);ensure_space(temp_root,member.file_size,reserve);p=temp_root/f'.zipmember.{uuid.uuid4().hex}.heicconv.part';h=hashlib.sha256();written=0
    try:
        progress.set('ZIP_MEMBER_STREAM',f'{Path(z.filename).name}::{member.filename}')
        with z.open(member) as s,p.open('xb',buffering=0) as d:
            while True:
                if STOP.is_set():raise InterruptedError('Interrupted streaming ZIP member')
                b=s.read(CHUNK)
                if not b:break
                d.write(b);h.update(b);written+=len(b);progress.add(len(b))
            d.flush();os.fsync(d.fileno())
        if written!=member.file_size:raise IOError('ZIP member size mismatch')
        return p,h.hexdigest()
    except BaseException:
        try:p.unlink(missing_ok=True)
        except OSError:pass
        raise

def reports(path,rows,s,cfg):
    path.mkdir(parents=True,exist_ok=True);fields=list(Row.__dataclass_fields__)
    with (path/'files.csv').open('w',newline='',encoding='utf-8-sig') as f:w=csv.DictWriter(f,fieldnames=fields);w.writeheader();[w.writerow(asdict(r)) for r in rows]
    d=asdict(s);d['configuration']=cfg;(path/'summary.json').write_text(json.dumps(d,indent=2),encoding='utf-8')
    lines=['HEIC/HEIF CONVERTER - FINAL REPORT','='*40,f'Run ID: {s.run_id}',f'Started: {s.started_at}',f'Finished: {s.finished_at}',f'Elapsed: {duration(s.elapsed_seconds)} ({s.elapsed_seconds:.2f}s)','',f'Ordinary HEIC/HEIF found: {s.ordinary_found}',f'ZIP archives found: {s.zip_archives_found}',f'ZIP HEIC/HEIF members found: {s.zip_members_found}',f'Converted: {s.converted}',f'Corrupted routed: {s.corrupted_routed}',f'Output conflicts: {s.conflicts}',f'Failed: {s.failed}',f'Originals deleted: {s.originals_deleted}',f'Originals preserved: {s.originals_preserved}',f'ZIP archives deleted: {s.archives_deleted}',f'ZIP archives preserved: {s.archives_preserved}',f'Source bytes: {s.source_bytes} ({human(s.source_bytes)})',f'Output bytes: {s.output_bytes} ({human(s.output_bytes)})',f'Capacity estimate: {s.capacity_required} ({human(s.capacity_required)})',f'Capacity free: {s.capacity_free} ({human(s.capacity_free)})',f'Capacity sufficient: {s.capacity_sufficient}',f'Delete-originals mode: {s.delete_originals}',f'Interrupted: {s.interrupted}',f'Dry run: {s.dry_run}']
    (path/'final_report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')

def parse(argv=None):
    p=argparse.ArgumentParser(description='Recursive HEIC/HEIF conversion to Android-compatible JPG or PNG.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('--source');p.add_argument('--output');p.add_argument('--format',choices=('jpg','png'),default='jpg');p.add_argument('--jpeg-quality',type=int,default=92);p.add_argument('--delete-originals',action='store_true');p.add_argument('--confirm-delete',default='');p.add_argument('--reserve-mb',type=int,default=512);p.add_argument('--heartbeat-minutes',type=int,choices=(30,60),default=30);p.add_argument('--report-dir');p.add_argument('--dry-run',action='store_true');p.add_argument('--verbose',action='store_true');p.add_argument('--version',action='version',version=f'%(prog)s {VERSION}');return p.parse_args(argv)

def main(argv=None):
    a=parse(argv)
    interactive=not a.source or not a.output
    if not a.source:a.source=input('Source directory: ').strip()
    if not a.output:a.output=input('Output directory: ').strip()
    if interactive:
        chosen=input(f'Output format [jpg/png] (default {a.format}): ').strip().lower()
        if chosen:a.format=chosen
        if a.format=='jpg':
            quality=input(f'JPEG quality 1-100 (default {a.jpeg_quality}): ').strip()
            if quality:a.jpeg_quality=int(quality)
        preserve=input('Preserve original HEIC/HEIF files? [Y/n]: ').strip().lower()
        if preserve=='n':
            phrase=input(f'Type {CONFIRM} to confirm deletion after verification: ').strip()
            a.delete_originals=True;a.confirm_delete=phrase
    if a.format not in ('jpg','png'):raise ValueError('Output format must be jpg or png')
    if not 1<=a.jpeg_quality<=100:raise ValueError('JPEG quality must be 1..100')
    if a.delete_originals and a.confirm_delete!=CONFIRM:raise ValueError(f'Deletion mode requires --confirm-delete {CONFIRM}')
    source,output=norm(a.source),norm(a.output)
    if not source.is_dir():raise ValueError(f'Source is not a directory: {source}')
    if source==output or within(source,output) or within(output,source):raise ValueError('Source and output must be separate, non-overlapping trees')
    output.mkdir(parents=True,exist_ok=True);corrupt=output/'CorruptedHEIC';temp=output/'.heic_converter/temp';run=dt.datetime.now().strftime('%Y%m%d_%H%M%S')+'_'+uuid.uuid4().hex[:8];report=norm(a.report_dir) if a.report_dir else output/'.heic_converter/reports'/run;report.mkdir(parents=True,exist_ok=True)
    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO,format='%(asctime)s %(levelname)s %(message)s',handlers=[logging.FileHandler(report/'transfer.log',encoding='utf-8'),logging.StreamHandler()],force=True)
    for s in (getattr(signal,'SIGINT',None),getattr(signal,'SIGTERM',None)):
        if s is not None:signal.signal(s,sig_handler)
    start=time.monotonic();summary=Summary(run_id=run,started_at=now(),dry_run=a.dry_run,delete_originals=a.delete_originals);rows=[];progress=Progress(a.heartbeat_minutes);reserve=max(0,a.reserve_mb)*1024*1024;fatal='';ext='.jpg' if a.format=='jpg' else '.png';fmt='JPEG' if a.format=='jpg' else 'PNG';cfg={'source':str(source),'output':str(output),'format':a.format,'jpeg_quality':a.jpeg_quality,'delete_originals':a.delete_originals,'reserve_mb':a.reserve_mb,'heartbeat_minutes':a.heartbeat_minutes,'dry_run':a.dry_run,'corrupted':str(corrupt)}
    try:
        if not a.dry_run:cleanup(output)
        ordinary,archives=scan(source,progress);summary.ordinary_found=len(ordinary);summary.zip_archives_found=len(archives);summary.zip_members_found=sum(len(x[1]) for x in archives);summary.source_bytes=sum(p.stat().st_size for p in ordinary)+sum(m.file_size for _,ms,_,_ in archives for m in ms);progress.total_items=summary.ordinary_found+summary.zip_members_found;progress.total_work=max(1,summary.source_bytes*3)
        factor=2 if fmt=='JPEG' else 6;summary.capacity_required=summary.source_bytes*factor;summary.capacity_free=shutil.disk_usage(nearest(output)).free;summary.capacity_sufficient=summary.capacity_free>=summary.capacity_required+reserve
        if not summary.capacity_sufficient and not a.dry_run:raise OSError('Output capacity preflight failed; no originals were deleted')
        for p in ordinary:
            target=(output/p.relative_to(source)).with_suffix(ext);row=Row(str(p),'ordinary',output=str(target),format=fmt,quality=a.jpeg_quality,source_size=p.stat().st_size,status='DRY_RUN' if a.dry_run else 'PLANNED');rows.append(row)
            if a.dry_run:continue
            try:
                sh,oh,osize,size,exif,ori,icc=convert_one(p,target,fmt,a.jpeg_quality,reserve,progress);row.source_sha256=sh;row.output_sha256=oh;row.output_size=osize;row.width,row.height=size;row.exif_preserved=exif;row.orientation_applied=ori;row.icc_preserved=icc;row.status='CONVERTED_VERIFIED';summary.converted+=1;summary.output_bytes+=osize
                if a.delete_originals:
                    if STOP.is_set():raise InterruptedError('Interrupted before HEIC deletion')
                    p.unlink();row.source_deleted=True;summary.originals_deleted+=1;row.status='CONVERTED_VERIFIED_ORIGINAL_DELETED'
                else:summary.originals_preserved+=1
                progress.complete(osize)
            except FileExistsError as e:row.status='OUTPUT_CONFLICT_ORIGINAL_PRESERVED';row.error=str(e);summary.conflicts+=1;summary.originals_preserved+=1;progress.fail()
            except InterruptedError:row.status='INTERRUPTED_ORIGINAL_PRESERVED';summary.originals_preserved+=1;progress.fail();raise
            except Exception as e:
                row.status='CORRUPT_OR_FAILED_ORIGINAL_PRESERVED';row.error=f'{type(e).__name__}: {e}';summary.failed+=1;summary.originals_preserved+=1
                try:
                    ct=corrupt/p.relative_to(source);digest,w=verified_copy_raw(p,ct,reserve,progress);row.status='CORRUPTED_ROUTED_ORIGINAL_PRESERVED';summary.corrupted_routed+=1
                except Exception as ce:row.error+='; corrupt routing failed: '+str(ce)
                progress.fail()
        for archive,members,all_regular,scan_error in archives:
            if scan_error or not members:
                summary.archives_preserved+=1;summary.failed+=1;rows.append(Row(str(archive),'zip_archive',source_size=archive.stat().st_size,status='ZIP_PRESERVED',error=scan_error or 'No HEIC/HEIF members'));continue
            archive_ok=True;member_rows=[]
            try:
                with zipfile.ZipFile(archive) as z:
                    for member in members:
                        target=zip_member_target(output,source,archive,member,ext);row=Row(f'{archive}::{member.filename}','zip_member',member.filename,str(target),fmt,a.jpeg_quality,member.file_size,status='PLANNED');rows.append(row);member_rows.append(row);staged=None
                        if a.dry_run:row.status='DRY_RUN_ZIP_MEMBER';continue
                        try:
                            staged,rawhash=stream_member(z,member,temp,reserve,progress);sh,oh,osize,size,exif,ori,icc=convert_one(staged,target,fmt,a.jpeg_quality,reserve,progress);row.source_sha256=rawhash;row.output_sha256=oh;row.output_size=osize;row.width,row.height=size;row.exif_preserved=exif;row.orientation_applied=ori;row.icc_preserved=icc;row.status='ZIP_MEMBER_CONVERTED_VERIFIED';summary.converted+=1;summary.output_bytes+=osize;progress.complete(osize)
                        except FileExistsError as e:archive_ok=False;row.status='ZIP_MEMBER_OUTPUT_CONFLICT_ARCHIVE_PRESERVED';row.error=str(e);summary.conflicts+=1;progress.fail()
                        except InterruptedError:archive_ok=False;row.status='ZIP_MEMBER_INTERRUPTED_ARCHIVE_PRESERVED';progress.fail();raise
                        except Exception as e:
                            archive_ok=False;row.status='ZIP_MEMBER_CORRUPT_ARCHIVE_PRESERVED';row.error=f'{type(e).__name__}: {e}';summary.failed+=1
                            if staged and staged.exists():
                                try:ct=zip_corrupt_target(corrupt,source,archive,member);digest,w=verified_copy_raw(staged,ct,reserve,progress);row.status='ZIP_MEMBER_CORRUPTED_ROUTED_ARCHIVE_PRESERVED';summary.corrupted_routed+=1
                                except Exception as ce:row.error+='; corrupt routing failed: '+str(ce)
                            progress.fail()
                        finally:
                            if staged:
                                try:staged.unlink(missing_ok=True)
                                except OSError:pass
            except InterruptedError:summary.archives_preserved+=1;raise
            except Exception as e:archive_ok=False;summary.failed+=1;logging.error('ZIP failure %s: %s',archive,e)
            if a.dry_run:summary.archives_preserved+=1
            elif a.delete_originals and archive_ok and len(members)==len(all_regular):
                archive.unlink();summary.archives_deleted+=1
                for r in member_rows:r.archive_deleted=True;r.status='ZIP_MEMBER_CONVERTED_VERIFIED_ARCHIVE_DELETED'
            else:
                summary.archives_preserved+=1
                if a.delete_originals:summary.originals_preserved+=len(members)
                if a.delete_originals and archive_ok and len(members)!=len(all_regular):logging.info('ZIP preserved because it contains non-HEIC files: %s',archive)
        if not a.delete_originals:summary.originals_preserved+=summary.zip_members_found
    except InterruptedError as e:summary.interrupted=True;fatal=str(e);logging.warning('Interrupted safely: %s',e)
    except Exception as e:fatal=f'{type(e).__name__}: {e}';logging.error('Stopped safely: %s',fatal)
    finally:
        if not a.dry_run:cleanup(output)
        if a.dry_run:summary.originals_preserved=summary.ordinary_found+summary.zip_members_found
        summary.elapsed_seconds=time.monotonic()-start;summary.finished_at=now();reports(report,rows,summary,cfg);progress.close()
    print(f'\nConverted: {summary.converted}; corrupt routed: {summary.corrupted_routed}; conflicts: {summary.conflicts}; failed: {summary.failed}; reports: {report}')
    if summary.interrupted:return 130
    if fatal:return 4
    return 1 if summary.failed or summary.conflicts else 0
if __name__=='__main__':raise SystemExit(main())
