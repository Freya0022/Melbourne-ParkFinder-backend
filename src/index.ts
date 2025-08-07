import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import spotRoutes from "./routes/spot.js";
import { db } from "./db.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Root welcome message
app.get("/", (req, res) => {
  res.send("🚗 Welcome to the Melbourne ParkFinder API!");
});

// Test DB connection
app.get("/api/testdb", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT 1");
    res.json({
      message: "✅ Database connected successfully!",
      result: rows,
    });
  } catch (err) {
    console.error("❌ DB connection failed:", err);
    res.status(500).json({ error: "Database connection failed", details: err });
  }
});

// Parking spots route
app.use("/api/spot", spotRoutes);

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
