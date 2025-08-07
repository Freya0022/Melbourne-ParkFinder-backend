# STREET SEGMENT

CREATE TABLE street_segments (
  ParkingZone INT,
  OnStreet VARCHAR(100),
  StreetFrom VARCHAR(100),
  StreetTo VARCHAR(100),
  Segment_ID INT
);

LOAD DATA LOCAL INFILE '/Users/ryanlieu/Desktop/Street Segments.csv'
INTO TABLE street_segments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM street_segments;

------------------------------


# PARKING BAYS

CREATE TABLE parking_bays (
  RoadSegmentID INT,
  KerbsideID INT,
  RoadSegmentDescription VARCHAR(255),
  Latitude DECIMAL(10,8),
  Longitude DECIMAL(11,8),
  LastUpdated DATE,
  Location VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/ryanlieu/Desktop/Parking Bays.csv'
INTO TABLE parking_bays
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * FROM parking_bays;

drop table parking_bays;

----------------------------------
# RESTRICTIONS

CREATE TABLE parking_restrictions (
  ParkingZone INT,
  Restriction_Days VARCHAR(20),
  Time_Restrict_Start TIME,
  Time_Restrict_End TIME,
  Restriction_Display VARCHAR(20)
);

LOAD DATA LOCAL INFILE '/Users/ryanlieu/Desktop/Parking Restriction.csv'
INTO TABLE parking_restrictions
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM parking_restrictions LIMIT 5;