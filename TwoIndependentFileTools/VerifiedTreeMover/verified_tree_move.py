#!/usr/bin/env python3
"""Verified movement of an entire directory tree without reorganizing it."""
from __future__ import annotations
import argparse, csv, datetime as dt, hashlib, json, logging, os, re, shutil, signal, sys, threading, time, uuid
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Optional

VERSION="1.0.0"; CHUNK=8*1024*1024
PART_RE=re.compile(r"^\..+\.[0-9a-f]{32}\.vtm\.part$")
STOP=threading.Event()

def now(): return dt.datetime.now(dt.timezone.utc).astimezone().isoformat(timespec="seconds")
def human(n):
    x=float(max(0,n))
    for u in ("B","KiB","MiB","GiB","TiB"):
        if x<1024 or u=="TiB": return f"{x:.2f} {u}"
        x/=1024

def duration(s):
    s=max(0,int(s)); h,r=divmod(s,3600); m,s=divmod(r,60)
    return f"{h:02d}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"

def on_signal(sig,_): STOP.set(); logging.warning("Interruption requested (signal %s)",sig)

def norm(v): return Path(os.path.expandvars(os.path.expanduser(v.strip().strip('"')))).resolve()
def within(child,parent):
    try: child.resolve().relative_to(parent.resolve()); return True
    except ValueError: return False

def check_layout(source,dest):
    if not source.is_dir(): raise ValueError(f"Source is not a directory: {source}")
    if source==dest or within(source,dest) or within(dest,source):
        raise ValueError("Source and destination must be separate, non-overlapping trees")

@dataclass
class Row:
    source:str; relative_path:str; destination:str; size:int=0; source_sha256:str=""; destination_sha256:str=""; status:str="PLANNED"; source_deleted:bool=False; bytes_written:int=0; elapsed_seconds:float=0.0; error:str=""
@dataclass
class Summary:
    version:str=VERSION; run_id:str=""; started_at:str=""; finished_at:str=""; source_files:int=0; source_directories:int=0; source_bytes:int=0; required_destination_bytes:int=0; free_destination_bytes:int=0; safety_reserve_bytes:int=0; moved_files:int=0; resumed_files:int=0; failed_files:int=0; retained_files:int=0; bytes_moved:int=0; removed_empty_directories:int=0; interrupted:bool=False; dry_run:bool=False; elapsed_seconds:float=0.0; capacity_sufficient:bool=False

class Progress:
    def __init__(self,heartbeat):
        self.start=time.monotonic(); self.stage="STARTING"; self.current=""; self.files=0; self.done=0; self.total_bytes=0; self.read=0; self.moved=0; self.lock=threading.Lock(); self.stop=threading.Event(); self.interval=heartbeat*60; self.next=self.interval
        self.thread=threading.Thread(target=self._beat,daemon=True); self.thread.start(); self.last=0
    def text(self):
        e=max(.001,time.monotonic()-self.start); rate=self.read/e; eta="n/a"
        if self.total_bytes and self.read<self.total_bytes and rate: eta=duration((self.total_bytes-self.read)/rate)
        return f"stage={self.stage} | file={self.current or '-'} | processed={self.done}/{self.files or '?'} | read={human(self.read)} | moved={human(self.moved)} | rate={human(int(rate))}/s | elapsed={duration(e)} | ETA={eta}"
    def emit(self,force=False,log=False):
        t=time.monotonic()
        with self.lock:
            text=self.text()
            if force or t-self.last>=1: print("\r"+text[:250].ljust(250),end="",flush=True); self.last=t
            if log: logging.info("PROGRESS %s",text)
    def set(self,stage,current=""): self.stage=stage; self.current=current; self.emit(True,True)
    def add(self,n): self.read+=n; self.emit()
    def complete(self,n): self.done+=1; self.moved+=n; self.emit(True,True)
    def fail(self): self.done+=1; self.emit(True,True)
    def _beat(self):
        while not self.stop.wait(5):
            e=time.monotonic()-self.start
            if e>=self.next:
                text=self.text(); logging.info("HEARTBEAT %s",text); print("\nHEARTBEAT: "+text,flush=True); self.next+=self.interval
    def close(self): self.stop.set(); self.thread.join(2); self.emit(True,True); print()

def iter_tree(root,progress):
    files=[]; dirs=[]
    for cur,names,fs in os.walk(root,followlinks=False):
        p=Path(cur); dirs.append(p); progress.set("DIRECTORY_SCAN",str(p))
        names[:]=sorted(x for x in names if not (p/x).is_symlink())
        for name in sorted(fs):
            q=p/name
            if q.is_symlink(): logging.warning("Skipping symbolic link: %s",q); continue
            if q.is_file(): files.append(q)
    return files,dirs

def hash_file(path,progress,label):
    h=hashlib.sha256()
    with path.open("rb",buffering=0) as f:
        while True:
            if STOP.is_set(): raise InterruptedError("Interrupted while hashing")
            b=f.read(CHUNK)
            if not b: break
            h.update(b); progress.add(len(b)); progress.current=label
    return h.hexdigest()

def nearest(path):
    while not path.exists() and path!=path.parent: path=path.parent
    return path

def ensure_space(path,need,reserve):
    free=shutil.disk_usage(nearest(path)).free
    if free<need+reserve: raise OSError(f"Insufficient destination space: need {human(need+reserve)}, free {human(free)}")

def fsync_dir(path):
    if os.name=="nt": return
    try:
        fd=os.open(path,os.O_RDONLY); os.fsync(fd); os.close(fd)
    except OSError: pass

def cleanup_parts(dest):
    count=0
    if not dest.exists(): return count
    for cur,_,files in os.walk(dest):
        for name in files:
            if PART_RE.match(name):
                p=Path(cur)/name
                try: p.unlink(); count+=1; logging.warning("Removed stale toolkit part: %s",p)
                except OSError as e: logging.warning("Could not remove stale part %s: %s",p,e)
    return count

def move_one(source,target,reserve,progress):
    started=time.monotonic(); size=source.stat().st_size
    progress.set("SOURCE_SHA256",str(source)); sh=hash_file(source,progress,str(source))
    target.parent.mkdir(parents=True,exist_ok=True)
    if target.exists():
        if not target.is_file(): raise FileExistsError(f"Destination path is not a file: {target}")
        progress.set("EXISTING_DESTINATION_SHA256",str(target)); dh=hash_file(target,progress,str(target))
        if dh!=sh: raise FileExistsError(f"Destination conflict (different content): {target}")
        if STOP.is_set(): raise InterruptedError("Interrupted before source deletion")
        source.unlink(); return "RESUMED_VERIFIED_EXISTING",sh,dh,0,time.monotonic()-started
    ensure_space(target.parent,size,reserve)
    part=target.parent/f".{target.name}.{uuid.uuid4().hex}.vtm.part"; written=0; stream=hashlib.sha256()
    try:
        progress.set("COPY_TO_PART",str(source))
        with source.open("rb",buffering=0) as src, part.open("xb",buffering=0) as dst:
            while True:
                if STOP.is_set(): raise InterruptedError("Interrupted during copy")
                b=src.read(CHUNK)
                if not b: break
                dst.write(b); stream.update(b); written+=len(b); progress.add(len(b))
            dst.flush(); os.fsync(dst.fileno())
        if stream.hexdigest()!=sh: raise IOError("Source changed during copy or streaming SHA-256 mismatch")
        progress.set("PART_SHA256",str(part)); ph=hash_file(part,progress,str(part))
        if ph!=sh: raise IOError("Destination .part SHA-256 mismatch")
        try: shutil.copystat(source,part,follow_symlinks=False)
        except OSError as e: logging.warning("Metadata preservation warning for %s: %s",source,e)
        os.replace(part,target); fsync_dir(target.parent)
        progress.set("FINAL_SHA256",str(target)); dh=hash_file(target,progress,str(target))
        if dh!=sh: raise IOError("Final destination SHA-256 mismatch; source retained")
        if STOP.is_set(): raise InterruptedError("Interrupted after finalization; source retained")
        source.unlink()
        return "MOVED_VERIFIED",sh,dh,written,time.monotonic()-started
    except BaseException:
        try: part.unlink(missing_ok=True)
        except OSError: pass
        raise

def write_reports(report,rows,summary,config):
    report.mkdir(parents=True,exist_ok=True)
    fields=list(Row.__dataclass_fields__)
    with (report/'files.csv').open('w',newline='',encoding='utf-8-sig') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); [w.writerow(asdict(r)) for r in rows]
    data=asdict(summary); data['configuration']=config
    (report/'summary.json').write_text(json.dumps(data,indent=2),encoding='utf-8')
    lines=["VERIFIED TREE MOVER - FINAL REPORT","="*40,f"Run ID: {summary.run_id}",f"Started: {summary.started_at}",f"Finished: {summary.finished_at}",f"Elapsed: {duration(summary.elapsed_seconds)} ({summary.elapsed_seconds:.2f}s)","",f"Source files: {summary.source_files}",f"Source directories: {summary.source_directories}",f"Source bytes: {summary.source_bytes} ({human(summary.source_bytes)})",f"Moved: {summary.moved_files}",f"Resumed from verified destination: {summary.resumed_files}",f"Failed: {summary.failed_files}",f"Retained source files: {summary.retained_files}",f"Bytes written: {summary.bytes_moved} ({human(summary.bytes_moved)})",f"Empty source directories removed: {summary.removed_empty_directories}",f"Capacity required: {summary.required_destination_bytes} ({human(summary.required_destination_bytes)})",f"Capacity free: {summary.free_destination_bytes} ({human(summary.free_destination_bytes)})",f"Safety reserve: {summary.safety_reserve_bytes} ({human(summary.safety_reserve_bytes)})",f"Capacity sufficient: {summary.capacity_sufficient}",f"Interrupted: {summary.interrupted}",f"Dry run: {summary.dry_run}"]
    (report/'final_report.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')

def parse(argv=None):
    p=argparse.ArgumentParser(description="Verified movement of an entire directory tree with exact structure preservation.",formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('--source'); p.add_argument('--destination'); p.add_argument('--reserve-mb',type=int,default=512); p.add_argument('--heartbeat-minutes',type=int,choices=(30,60),default=30); p.add_argument('--report-dir'); p.add_argument('--dry-run',action='store_true'); p.add_argument('--verbose',action='store_true'); p.add_argument('--version',action='version',version=f'%(prog)s {VERSION}')
    return p.parse_args(argv)

def main(argv=None):
    a=parse(argv)
    if not a.source: a.source=input('Source directory tree: ').strip()
    if not a.destination: a.destination=input('Destination directory: ').strip()
    source,dest=norm(a.source),norm(a.destination); check_layout(source,dest); dest.mkdir(parents=True,exist_ok=True)
    run=dt.datetime.now().strftime('%Y%m%d_%H%M%S')+'_'+uuid.uuid4().hex[:8]
    report=norm(a.report_dir) if a.report_dir else dest/'.verified_tree_move/reports'/run; report.mkdir(parents=True,exist_ok=True)
    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO,format='%(asctime)s %(levelname)s %(message)s',handlers=[logging.FileHandler(report/'transfer.log',encoding='utf-8'),logging.StreamHandler()],force=True)
    for s in (getattr(signal,'SIGINT',None),getattr(signal,'SIGTERM',None)):
        if s is not None: signal.signal(s,on_signal)
    start=time.monotonic(); summary=Summary(run_id=run,started_at=now(),dry_run=a.dry_run); rows=[]; progress=Progress(a.heartbeat_minutes); reserve=max(0,a.reserve_mb)*1024*1024; fatal=''
    config={'source':str(source),'destination':str(dest),'reserve_mb':max(0,a.reserve_mb),'heartbeat_minutes':a.heartbeat_minutes,'dry_run':a.dry_run,'report_dir':str(report)}
    try:
        if not a.dry_run: cleanup_parts(dest)
        files,dirs=iter_tree(source,progress); summary.source_files=len(files); summary.source_directories=len(dirs); summary.source_bytes=sum(x.stat().st_size for x in files); progress.files=len(files); progress.total_bytes=max(1,summary.source_bytes*4)
        required=sum(x.stat().st_size for x in files if not (dest/x.relative_to(source)).exists()); free=shutil.disk_usage(nearest(dest)).free
        summary.required_destination_bytes=required; summary.free_destination_bytes=free; summary.safety_reserve_bytes=reserve; summary.capacity_sufficient=free>=required+reserve
        logging.info("PREFLIGHT files=%d bytes=%s required=%s free=%s reserve=%s",len(files),human(summary.source_bytes),human(required),human(free),human(reserve))
        for x in files: rows.append(Row(str(x),str(x.relative_to(source)),str(dest/x.relative_to(source)),x.stat().st_size,status='DRY_RUN' if a.dry_run else 'PLANNED'))
        if not summary.capacity_sufficient and not a.dry_run: raise OSError("Destination capacity preflight failed; no source files were deleted")
        if not a.dry_run:
            progress.set('CREATE_DESTINATION_DIRECTORIES',str(dest))
            for directory in sorted(dirs,key=lambda x:len(x.parts)):
                relative=directory.relative_to(source)
                (dest/relative).mkdir(parents=True,exist_ok=True)
            for row in rows:
                if STOP.is_set(): raise InterruptedError("Interrupted before next file")
                try:
                    status,sh,dh,written,elapsed=move_one(Path(row.source),Path(row.destination),reserve,progress); row.status=status; row.source_sha256=sh; row.destination_sha256=dh; row.bytes_written=written; row.elapsed_seconds=elapsed; row.source_deleted=True
                    summary.bytes_moved+=written
                    if status.startswith('RESUMED'): summary.resumed_files+=1
                    else: summary.moved_files+=1
                    progress.complete(written); logging.info("%s %s -> %s",status,row.source,row.destination)
                except InterruptedError:
                    row.status='INTERRUPTED_SOURCE_RETAINED'; row.error='Interrupted'; progress.fail(); raise
                except Exception as e:
                    row.status='FAILED_SOURCE_RETAINED'; row.error=f'{type(e).__name__}: {e}'; summary.failed_files+=1; progress.fail(); logging.error("Source retained %s: %s",row.source,e)
                    if 'Insufficient destination space' in str(e): raise
            progress.set('REMOVE_EMPTY_SOURCE_DIRECTORIES',str(source))
            for d in sorted(dirs,key=lambda x:len(x.parts),reverse=True):
                try: d.rmdir(); summary.removed_empty_directories+=1; logging.info("Removed empty source directory: %s",d)
                except OSError: pass
    except InterruptedError as e: summary.interrupted=True; fatal=str(e); logging.warning("Interrupted safely: %s",e)
    except Exception as e: fatal=f'{type(e).__name__}: {e}'; logging.error("Stopped safely: %s",fatal)
    finally:
        if not a.dry_run: cleanup_parts(dest)
        summary.retained_files=sum(1 for r in rows if not r.source_deleted); summary.elapsed_seconds=time.monotonic()-start; summary.finished_at=now(); write_reports(report,rows,summary,config); progress.close()
    print(f"\nMoved: {summary.moved_files}; resumed: {summary.resumed_files}; failed: {summary.failed_files}; retained: {summary.retained_files}; reports: {report}")
    if summary.interrupted:return 130
    if fatal:return 4
    return 1 if summary.failed_files else 0
if __name__=='__main__': raise SystemExit(main())
