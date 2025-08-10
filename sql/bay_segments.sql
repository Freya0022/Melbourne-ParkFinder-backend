use parking_db;

SELECT DISTINCT ss.*, pb.*
FROM street_segments ss
JOIN parking_bays pb
  ON ss.Segment_ID = pb.RoadSegmentID;

CREATE TABLE bay_segments AS
SELECT DISTINCT ss.*, pb.*
FROM street_segments ss
JOIN parking_bays pb
  ON ss.Segment_ID = pb.RoadSegmentID;