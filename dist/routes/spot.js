import { Router } from "express";
import { db } from "../db.js";
const router = Router();
router.get("/", async (req, res) => {
    try {
        const [rows] = await db.query("SELECT * FROM spot");
        res.json(rows);
    }
    catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error fetching parking spots" });
    }
});
export default router;
//# sourceMappingURL=spot.js.map