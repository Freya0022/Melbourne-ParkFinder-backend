import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import spotRoutes from "./routes/spot.js";
import { getDb } from "./db.js";
import { request, Agent } from "undici";
import dns from "node:dns";

dotenv.config();
const app = express();
function flattenErr(err: any) {
  if (err && err.name === "AggregateError" && Array.isArray((err as any).errors)) {
    return (err as any).errors
      .map((e: any) => String(e?.cause ?? e))
      .join(" | ");
  }
  return String(err?.cause ?? err);
}
const PORT: number = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
const ipv4Agent = new Agent({
  connect: {
    lookup: (hostname, options, cb) => dns.lookup(hostname, { ...options, family: 4 }, cb),
  },
});

app.use(cors({origin: "http://54.253.18.41:8080"}));
app.use(express.json());
// Root welcome message
app.get("/", (req, res) => {
    res.send("🚗 Welcome to the Melbourne ParkFinder API!");
});

// Health check 
app.get("/health", (_req, res) => {
    res.json({ ok: true });
});

// Test DB connection
app.get("/api/testdb", async (req, res) => {
    try {
        const pool = await getDb();
        const [rows] = await pool.query("SELECT 1");
        res.json({
            message: "✅ Database connected successfully!",
            result: rows,
        });
    }
    catch (err) {
        console.error("❌ DB connection failed:", err);
        res.status(500).json({ error: "Database connection failed", details: err });
    }
});
// Parking spots route
app.use("/api/spot", spotRoutes);

// geo api
app.get("/api/geocode", async (req, res) => {
  const q = String(req.query.q || "").trim();
  if (!q) return res.status(400).json({ error: "Missing query" });

  const params = new URLSearchParams({
    format: "json",
    q,
    limit: "5",
    addressdetails: "1",
    countrycodes: "au",
    // email: "cfan0042@student.monash.edu", // optional extra
  });
  const url = `https://nominatim.openstreetmap.org/search?${params}`;

  try {
    console.log("[/api/geocode] →", url);

    const { statusCode, body } = await request(url, {
      headers: {
        "user-agent": "Melbourne ParkFinder/1.0 (cfan0042@student.monash.edu)",
        "accept": "application/json",
        "accept-language": "en-AU",
      },
      dispatcher: ipv4Agent, // comment out if you don't want to force IPv4
    });

    const text = await body.text();

    if (statusCode < 200 || statusCode >= 300) {
      console.error("[/api/geocode] upstream", statusCode, text.slice(0, 300));
      return res.status(statusCode).json({
        error: "Upstream geocoding error",
        status: statusCode,
        body: text.slice(0, 500),
      });
    }

    try {
      const json = JSON.parse(text);
      return res.json(json);
    } catch {
      console.error("[/api/geocode] non-JSON 200:", text.slice(0, 300));
      return res.status(502).json({ error: "Invalid JSON from geocoder" });
    }
  } catch (err: any) {
    const detail = flattenErr(err);
    console.error("[/api/geocode] fetch failed:", detail);
    return res.status(502).json({ error: "Failed to reach geocoding service", detail });
  }
});


app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running at http://0.0.0.0:${PORT}`);
});
//# sourceMappingURL=index.js.map