import { Router } from "express";
import { getDb } from "../db.js";
import type { RowDataPacket } from "mysql2";

interface Spot extends RowDataPacket {
  id: number;
  parkingZone: string;
  area: string;
  location: string;
  restriction: string;
  hour: number;
  latitude:number;
  longitude: number;
  restrictDisplay: string;
}

const router = Router();

router.get("/", async (req, res) => {
  try {
    const pool = await getDb();
    const [rows] = await pool.query<Spot[]>(`
      SELECT  
      ROW_NUMBER() OVER () AS id, 
      ParkingZone AS parkingZone, 
      OnStreet AS area, 
      RoadSegmentDescription AS location,
      Restriction_Summary AS restriction,
      CAST(REGEXP_SUBSTR(restriction_display, '[0-9]+') AS UNSIGNED) AS hour,
      Latitude AS latitude,
      Longitude AS longitude,
      Restriction_Display AS restrictDisplay
      FROM bay_segments
    `);

    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error fetching parking spots" });
  }
});

export default router;
