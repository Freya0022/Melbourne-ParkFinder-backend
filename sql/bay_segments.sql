USE parking_db;
DROP TABLE bay_segments;

/* 

SELECT ss.*, pb.*
FROM street_segments ss
JOIN parking_bays pb
  ON ss.Segment_ID = pb.RoadSegmentID;

CREATE TABLE bay_segments AS
SELECT ss.*, pb.*
FROM street_segments ss
JOIN parking_bays pb
  ON ss.Segment_ID = pb.RoadSegmentID;

*/

--------------------------------------
/* 

SELECT 
  ss.Segment_ID, ss.ParkingZone, ss.OnStreet, ss.StreetFrom, ss.StreetTo, pb.RoadSegmentDescription, pb.Latitude, pb.Longitude,
  r.Restriction_Days, r.Time_Restrict_Start, r.Time_Restrict_End, r.Restriction_Display
FROM street_segments ss
INNER JOIN parking_bays pb ON pb.RoadSegmentID = ss.Segment_ID
INNER JOIN parking_restrictions r   ON r.ParkingZone   = ss.ParkingZone;

*/


WITH one_bay_per_segment AS (
    SELECT pb.*
    FROM parking_bays pb
    JOIN (
        SELECT RoadSegmentID, MIN(KerbsideID) AS min_kerbside
        FROM parking_bays
        GROUP BY RoadSegmentID
    ) x ON pb.RoadSegmentID = x.RoadSegmentID
       AND pb.KerbsideID = x.min_kerbside
)
SELECT 
    ss.Segment_ID,
    ss.ParkingZone,
    ss.OnStreet,
    ss.StreetFrom,
    ss.StreetTo,
    ob.RoadSegmentDescription,
    ob.Latitude,
    ob.Longitude,
    r.Restriction_Days,
    r.Time_Restrict_Start,
    r.Time_Restrict_End,
    r.Restriction_Display
FROM street_segments ss
INNER JOIN one_bay_per_segment ob
    ON ob.RoadSegmentID = ss.Segment_ID
INNER JOIN parking_restrictions r
    ON r.ParkingZone = ss.ParkingZone;

# Create the segment bay table with restrictions
CREATE TABLE bay_segments AS
WITH one_bay_per_segment AS (
    SELECT pb.*
    FROM parking_bays pb
    JOIN (
        SELECT RoadSegmentID, MIN(KerbsideID) AS min_kerbside
        FROM parking_bays
        GROUP BY RoadSegmentID
    ) x ON pb.RoadSegmentID = x.RoadSegmentID
       AND pb.KerbsideID = x.min_kerbside
)
SELECT 
    ss.Segment_ID,
    ss.ParkingZone,
    ss.OnStreet,
    ss.StreetFrom,
    ss.StreetTo,
    ob.RoadSegmentDescription,
    ob.Latitude,
    ob.Longitude,
    r.Restriction_Days,
    r.Time_Restrict_Start,
    r.Time_Restrict_End,
    r.Restriction_Display
FROM street_segments ss
INNER JOIN one_bay_per_segment ob
    ON ob.RoadSegmentID = ss.Segment_ID
INNER JOIN parking_restrictions r
    ON r.ParkingZone = ss.ParkingZone;