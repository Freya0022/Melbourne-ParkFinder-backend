CREATE DATABASE test2_db;
USE test2_db;


DROP TABLE test_parking_restriction;
DROP TABLE test_parking_zone;

DROP TABLE temp_parking_restriction

CREATE TABLE test_parking_restriction (
    test_restriction_id INT AUTO_INCREMENT,
    test_parking_zone INT(4) NOT NULL,
    test_restriction_days VARCHAR(20) NOT NULL,
    test_start_time TIME NOT NULL,
    test_end_time TIME NOT NULL,
    test_restriction_desc VARCHAR(255) NOT NULL,
    PRIMARY KEY (test_restriction_id)
);

CREATE TABLE test_parking_zone (
    test_parking_zone_id INT(4) NOT NULL,
    test_restriction_id INT NOT NULL,
    PRIMARY KEY (test_parking_zone_id, test_restriction_id)
);


ALTER TABLE test_parking_zone
ADD CONSTRAINT fk_test_restriction_parking_zone
FOREIGN KEY (test_restriction_id)
REFERENCES test_parking_restriction(test_restriction_id);



CREATE TABLE test_street_segment (
    test_segment_id INT(4) NOT NULL,
    test_parking_zone_id INT(4) NOT NULL,
    test_on_street VARCHAR(255) NOT NULL,
    test_street_from VARCHAR(255) NOT NULL,
    test_street_to VARCHAR(255),
    PRIMARY KEY (test_segment_id, test_parking_zone_id))
);

ALTER TABLE test_street_segment
ADD CONSTRAINT fk_test_parking_zone_segment
FOREIGN KEY (test_parking_zone_id)
REFERENCES test_parking_zone(test_parking_zone_id);

CREATE TABLE test_parking_bay (
    test_location VARCHAR(255) NOT NULL,
    test_segment_id INT(4) NOT NULL,
    test_kerbside_id INT(4),
    test_road_segment_desc VARCHAR(255) NOT NULL,
    PRIMARY KEY (test_location)
)

ALTER TABLE test_parking_bay
ADD CONSTRAINT fk_test_segment_bay
FOREIGN KEY (test_segment_id)
REFERENCES test_street_segment(test_segment_id);

CREATE TABLE temp_parking_restriction (
    ParkingZone INT(4) NOT NULL,
    Restriction_Days VARCHAR(20) NOT NULL,
    Time_Restrictions_Start TIME NOT NULL,
    Time_Restrict_End TIME NOT NULL,
    Restriction_Display VARCHAR(255) NOT NULL
);

LOAD DATA LOCAL INFILE
'C:/Users/charl/Desktop/Uni/Monash/2nd Year/Semester 2/FIT5120 - Industry Experience Studio Project/Project/Parking Restriction.csv'
INTO TABLE temp_parking_restriction
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

INSERT INTO test_parking_restriction (
    test_parking_zone, 
    test_restriction_days, 
    test_start_time, 
    test_end_time, 
    test_restriction_desc
)
SELECT 
    ParkingZone, 
    Restriction_Days, 
    Time_Restrictions_Start, 
    Time_Restrict_End, 
    Restriction_Display
FROM temp_parking_restriction;

SELECT * FROM test_parking_restriction;

INSERT INTO test_parking_zone (test_parking_zone_id, test_restriction_id)
SELECT test_parking_zone, test_restriction_id
FROM test_parking_restriction;

SELECT * FROM test_parking_zone

CREATE TABLE temp_street_segments (
  ParkingZone INT,
  OnStreet VARCHAR(100),
  StreetFrom VARCHAR(100),
  StreetTo VARCHAR(100),
  Segment_ID INT
);

LOAD DATA LOCAL INFILE
'C:/Users/charl/Desktop/Uni/Monash/2nd Year/Semester 2/FIT5120 - Industry Experience Studio Project/Project/Street Segments.csv'
INTO TABLE temp_street_segments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

INSERT INTO test_street_segment (
  test_segment_id,
  test_parking_zone_id,
  test_on_street,
  test_street_from,
  test_street_to
)
SELECT
  Segment_ID,
  ParkingZone,
  OnStreet,
  StreetFrom,
  StreetTo
FROM temp_street_segments;

SELECT * FROM test_street_segment;

ALTER TABLE test_street_segment
ADD PRIMARY KEY (test_segment_id, test_parking_zone_id);
SELECT DISTINCT ParkingZone
FROM temp_street_segments
WHERE ParkingZone NOT IN (
  SELECT test_parking_zone_id
  FROM test_parking_zone
);