//import admin from "firebase-admin";
//import fs from "fs";
//import path from "path";
//import { fileURLToPath } from "url";

// ✅ Fix __dirname
//const __filename = fileURLToPath(import.meta.url);
//const __dirname = path.dirname(__filename);

// ✅ Load Firebase key
//const serviceAccount = JSON.parse(
  //fs.readFileSync(
   // path.join(__dirname, "../firebase-key.json"),
    //"utf8"
 // )
//);

// ✅ ✅ SIMPLE INIT (NO apps check ❌)
//admin.initializeApp({
  //credential: admin.credential.cert(serviceAccount),
//});

// =====================================================
// ✅ SEND NOTIFICATION
// =====================================================
export const sendNotification = async (token, title, body) => {
  try {
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title,
        body,
      },
    });

    console.log("✅ Notification sent");
  } catch (err) {
    console.log("❌ Notification error:", err.message);
  }
};