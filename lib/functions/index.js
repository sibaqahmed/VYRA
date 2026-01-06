const functions = require("firebase-functions");
const jwt = require("jsonwebtoken");
const cors = require("cors")({ origin: true });

// 🔑 Load secrets from Firebase config
const PRIVATE_KEY = functions
  .config()
  .jaas
  .private_key
  .replace(/\\n/g, "\n");

const APP_ID = "vpaas-magic-cookie-2fbbf37f24184f5eb71ad71a6b5a3ac3";

// 🔹 FULL KEY ID (Tenant/KeyId)
const KID =
  "vpaas-magic-cookie-2fbbf37f24184f5eb71ad71a6b5a3ac3/c39c6e";

// 🚀 JWT CLOUD FUNCTION
exports.jwt = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const { name, moderator, room } = req.query;

    if (!name) {
      return res.status(400).json({ error: "Missing name" });
    }

    const payload = {
      aud: "jitsi",
      iss: "chat",
      sub: APP_ID,

      // 🔐 REQUIRED BY JAAS
      room: room || "*",

      exp: Math.floor(Date.now() / 1000) + 60 * 60,

      context: {
        user: {
          name,
          moderator: moderator === "true",
        },
        features: {
          livestreaming: false,
          recording: false,
          transcription: false,
        },
      },
    };

    try {
      const token = jwt.sign(payload, PRIVATE_KEY, {
        algorithm: "RS256",
        header: {
          kid: KID,
          typ: "JWT",
        },
      });

      return res.json({ token });
    } catch (err) {
      console.error("JWT Error:", err);
      return res.status(500).json({ error: "JWT generation failed" });
    }
  });
});
