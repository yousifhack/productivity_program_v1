const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Secret from: firebase functions:secrets:set GEMINI_API_KEY
exports.myGuySend = functions.https.onCall(
  { region: "us-central1", secrets: ["GEMINI_API_KEY"] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
    }

    const text = (request.data?.text ?? "").toString().trim();
    if (!text) {
      return { ok: true, ignored: true };
    }

    // Save user message
    const userRef = admin.firestore().collection("users").doc(uid);
    const aiMsgs = userRef.collection("aiMessages");
    await aiMsgs.add({
      role: "user",
      text,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new functions.https.HttpsError("failed-precondition", "Missing GEMINI_API_KEY.");
    }

    // Gemini REST API (Developer API)
    // Use v1 (stable) + a current model.
    const model = "gemini-2.5-flash";

    const url =
      `https://generativelanguage.googleapis.com/v1/models/${model}:generateContent?key=${apiKey}`;

    const payload = {
      contents: [
        {
          role: "user",
          parts: [{ text }],
        },
      ],
      generationConfig: {
        temperature: 0.6,
        maxOutputTokens: 350,
      },
    };

    let aiText = "";
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const json = await res.json();

      if (!res.ok) {
        throw new Error(JSON.stringify(json));
      }

      aiText =
        json?.candidates?.[0]?.content?.parts?.map((p) => p.text).join("")?.trim() ||
        "I’m here. Try again.";
    } catch (e) {
      throw new functions.https.HttpsError(
        "internal",
        `Gemini error: ${e?.message ?? e}`
      );
    }

    // Save AI message
    await aiMsgs.add({
      role: "ai",
      text: aiText,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { ok: true };
  }
);
