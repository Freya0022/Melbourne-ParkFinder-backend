import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import spotRoutes from "./routes/spot.js";
import { getDb } from "./db.js";
dotenv.config();
const app = express();
const PORT: number = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
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
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running at http://0.0.0.0:${PORT}`);
});
//# sourceMappingURL=index.js.map