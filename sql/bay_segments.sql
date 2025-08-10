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

WITH last_updated_bay AS (
  SELECT sub.*
  FROM (
    SELECT
      pb.*,
      ROW_NUMBER() OVER (
        PARTITION BY pb.RoadSegmentID
        ORDER BY pb.LastUpdated DESC
      ) AS rn
    FROM parking_bays pb
  ) sub
  WHERE rn = 1
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
  ob.LastUpdated,
  r.Restriction_Days,
  r.Time_Restrict_Start,
  r.Time_Restrict_End,
  r.Restriction_Display
FROM street_segments ss
INNER JOIN last_updated_bay ob
  ON ob.RoadSegmentID = ss.Segment_ID
INNER JOIN parking_restrictions r
  ON r.ParkingZone = ss.ParkingZone;

# Create the segment bay table with restrictions
CREATE TABLE bay_segments AS
WITH last_updated_bay AS (
  SELECT *
  FROM (
    SELECT
      pb.*,
      ROW_NUMBER() OVER (
        PARTITION BY pb.RoadSegmentID
        ORDER BY pb.LastUpdated DESC
      ) AS rn
    FROM parking_bays pb
  ) x
  WHERE rn = 1
)
SELECT 
  ss.Segment_ID,
  ss.ParkingZone,
  ss.OnStreet,
  ss.StreetFrom,
  ss.StreetTo,
  lub.RoadSegmentDescription,
  lub.Latitude,
  lub.Longitude,
  lub.LastUpdated,
  r.Restriction_Days,
  r.Time_Restrict_Start,
  r.Time_Restrict_End,
  r.Restriction_Display
FROM street_segments ss
INNER JOIN last_updated_bay lub
  ON lub.RoadSegmentID = ss.Segment_ID
INNER JOIN parking_restrictions r
  ON r.ParkingZone = ss.ParkingZone;

ALTER TABLE bay_segments ADD COLUMN Restriction_Summary varchar(120);

UPDATE bay_segments
SET Restriction_Summary = CONCAT(
  restriction_days, ' ',
  CASE WHEN MINUTE(time_restrict_start)=0
       THEN LOWER(DATE_FORMAT(time_restrict_start,'%l%p'))
       ELSE LOWER(DATE_FORMAT(time_restrict_start,'%l:%i%p')) END,
  ' to ',
  CASE WHEN MINUTE(time_restrict_end)=0
       THEN LOWER(DATE_FORMAT(time_restrict_end,'%l%p'))
       ELSE LOWER(DATE_FORMAT(time_restrict_end,'%l:%i%p')) END,
  ' ',
  restriction_display
);