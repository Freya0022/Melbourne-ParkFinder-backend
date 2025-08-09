import { Router } from "express";
import { db } from "../db.js";
const router = Router();
router.get("/", async (req, res) => {
    try {
        const [rows] = await db.query(`
      SELECT  ROW_NUMBER() OVER () AS id, ParkingZone AS parkingZone, OnStreet AS area, RoadSegmentDescription AS location
      FROM bay_segments
    `);
        res.json(rows);
    }
    catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error fetching parking spots" });
    }
});
export default router;
//# sourceMappingURL=spot.js.map