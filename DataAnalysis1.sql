select * from `upbeat-task-436721-c5.bike_share.bike_share_data` 

--Adding 
ALTER TABLE `upbeat-task-436721-c5.bike_share.bike_share_data` 
ADD COLUMN day_of_week STRING;


UPDATE `upbeat-task-436721-c5.bike_share.bike_share_data` 
SET day_of_week = 
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 1 THEN "Sunday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 2 THEN "Monday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 3 THEN "Tuesday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 4 THEN "Wednesday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 5 THEN "Thursday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 6 THEN "Friday"
    WHEN EXTRACT(DAYOFWEEK FROM TIMESTAMP(started_at)) = 7 THEN "Saturday"
  END
WHERE TRUE;

ALTER TABLE `upbeat-task-436721-c5.bike_share.bike_share_data` 
ADD COLUMN month STRING;


UPDATE `upbeat-task-436721-c5.bike_share.bike_share_data` 
SET month = 
  CASE 
    WHEN EXTRACT(MONTH FROM started_at) = 1 THEN "January"
    WHEN EXTRACT(MONTH FROM started_at) = 2 THEN "February"
    WHEN EXTRACT(MONTH FROM started_at) = 3 THEN "March"
    WHEN EXTRACT(MONTH FROM started_at) = 4 THEN "April"
    WHEN EXTRACT(MONTH FROM started_at) = 5 THEN "May"
    WHEN EXTRACT(MONTH FROM started_at) = 6 THEN "June"
    WHEN EXTRACT(MONTH FROM started_at) = 7 THEN "July"
    WHEN EXTRACT(MONTH FROM started_at) = 8 THEN "August"
    WHEN EXTRACT(MONTH FROM started_at) = 9 THEN "September"
    WHEN EXTRACT(MONTH FROM started_at) = 10 THEN "October"
    WHEN EXTRACT(MONTH FROM started_at) = 11 THEN "November"
    WHEN EXTRACT(MONTH FROM started_at) = 12 THEN "December"
  END
WHERE TRUE;


SELECT
  started_at,
  ended_at,
  ride_length,
  FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(ride_length * 60 AS INT64))) AS ride_duration
FROM
  `upbeat-task-436721-c5.bike_share.bike_share_data`

-- ALTER TABLE upbeat-task-436721-c5.bike_share.bike_share_data
-- ADD COLUMN ride_length INT64;

-- UPDATE upbeat-task-436721-c5.bike_share.bike_share_data
-- SET ride_length = TIMESTAMP_DIFF(ended_At, started_At, MINUTE)
-- WHERE started_At IS NOT NULL AND ended_At IS NOT NULL;

ALTER TABLE `upbeat-task-436721-c5.bike_share.bike_share_data`
ADD COLUMN ride_duration STRING;

UPDATE `upbeat-task-436721-c5.bike_share.bike_share_data`
SET ride_duration = FORMAT_TIMESTAMP('%H:%M:%S', TIMESTAMP_SECONDS(CAST(ride_length * 60 AS INT64)))
WHERE ride_length IS NOT NULL;

--checking for ride_duration lessthan a minute and morethan 12 minutes
SELECT COUNT(ride_duration) as less_than_min
FROM upbeat-task-436721-c5.bike_share.bike_share_data
where ride_duration <= "00:01:00"

--removed ride_duration which is lessthan a minute and morethan 12 minutes
SELECT COUNT(ride_duration) as more_than_12hr
FROM upbeat-task-436721-c5.bike_share.bike_share_data
where ride_duration >= "12:00:00"

DELETE FROM upbeat-task-436721-c5.bike_share.bike_share_data
WHERE ride_duration >= "12:00:00"

DELETE FROM upbeat-task-436721-c5.bike_share.bike_share_data
WHERE ride_duration <= "00:01:00"

select count(*) as total_rides
from upbeat-task-436721-c5.bike_share.bike_share_data

--rides per rider
select rider, count(*) as total_rides_per_rider
from upbeat-task-436721-c5.bike_share.bike_share_data
group by rider

--rides per bike_type and rider
select bike_type, rider, count(*) as total_rides
from upbeat-task-436721-c5.bike_share.bike_share_data
group by rider, bike_type

--avergae time per rider
SELECT
  rider,
  bike_type,
  ROUND(AVG(ride_length), 2) as avg_time_rider
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY
  rider,
  bike_type;

--Day and month with the most ride in 2023
SELECT 
  day_of_week, month, COUNT(ride_id) as rides_per_day_month
FROM upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY 
  day_of_week, month
ORDER BY 
  rides_per_day_month DESC;

--Average time per each day
SELECT
  day_of_week, 
  ROUND(AVG(ride_length), 2) as avg_time_per_day
FROM 
  upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY 
  day_of_week
ORDER BY
  avg_time_per_day DESC;

-- rides per day for casual and member rider
SELECT
  day_of_week, 
  COUNT(ride_id) as ride_count_casual
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'casual'
GROUP BY 
  day_of_week

-- member
SELECT
  day_of_week, 
  COUNT(ride_id) as ride_count_casual
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'member'
GROUP BY 
  day_of_week

--ride count per rider and day_of_week (both member and casual) and their total and grand total
WITH ride_counts AS(
  SELECT
    rider,
    day_of_week, 
    COUNT(ride_id) as ride_count_per_rider
  FROM
    upbeat-task-436721-c5.bike_share.bike_share_data
  GROUP BY 
    day_of_week,
    rider
)
SELECT
  rider, 
  CAST(day_of_week AS STRING) as day_of_week,
  ride_count_per_rider
FROM
  ride_counts

UNION ALL

SELECT
  CONCAT(rider, '_total') as rider,
  "total" AS day_of_week,
  COALESCE(SUM(ride_count_per_rider), 0) as ride_count_per_rider
FROM
  ride_counts
GROUP BY
  rider
ORDER BY
  rider,
  ride_count_per_rider DESC,
  day_of_week = "total",
  day_of_week;


-- using ROLLUP
WITH ride_summary AS (
  SELECT
    rider,
    day_of_week, 
    COUNT(day_of_week) AS ride_count_per_day
  FROM
    upbeat-task-436721-c5.bike_share.bike_share_data
  GROUP BY
    ROLLUP(rider, day_of_week)
)

SELECT
  CASE
    -- Label for Grand Total row when both rider and day_of_week are NULL
    WHEN rider IS NULL AND day_of_week IS NULL THEN 'Grand Total'
    -- Label as rider_total for subtotals when day_of_week is NULL
    WHEN day_of_week IS NULL THEN CONCAT(rider, '_total')
    -- Normal rows retain the rider value
    ELSE rider
  END AS rider,

  CASE
    -- Replace NULL in day_of_week with 'total' for subtotal rows
    WHEN day_of_week IS NULL THEN 'total'
    -- Regular rows keep the day_of_week as a string
    ELSE CAST(day_of_week AS STRING)
  END AS day_of_week,

  ride_count_per_day

FROM ride_summary
ORDER BY
  CASE WHEN rider = 'Grand Total' THEN 1 ELSE 0 END,  -- Ensure Grand Total comes last
  rider,
  day_of_week;


--ride count per rider and month (both member and casual) and their total and grand total
WITH ride_summary AS (
  SELECT
    rider,
    month, 
    COUNT(month) AS ride_count_per_month
  FROM
    upbeat-task-436721-c5.bike_share.bike_share_data
  GROUP BY
    ROLLUP(rider, month)
)

SELECT
  CASE
    -- Label for Grand Total row when both rider and day_of_week are NULL
    WHEN rider IS NULL AND month IS NULL THEN 'Grand Total'
    -- Label as rider_total for subtotals when day_of_week is NULL
    WHEN month IS NULL THEN CONCAT(rider, '_total')
    -- Normal rows retain the rider value
    ELSE rider
  END AS rider,

  CASE
    -- Replace NULL in day_of_week with 'total' for subtotal rows
    WHEN month IS NULL THEN 'total'
    -- Regular rows keep the day_of_week as a string
    ELSE CAST(month AS STRING)
  END AS month,

  ride_count_per_month

FROM ride_summary
ORDER BY
  CASE WHEN rider = 'Grand Total' THEN 1 ELSE 0 END,  -- Ensure Grand Total comes last
  rider,
  month;


-- rides per hour for member and casual
SELECT
  rider,
  started_at,
  EXTRACT(HOUR FROM started_at) as hour_started,
  COUNT(*) as total_rides
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY 
  started_at,
  rider,
  hour_started;


-- rides and their time difference in hours
SELECT
  rider,
  started_at,
  ended_at,
  EXTRACT(HOUR FROM started_at) as hour_started,
  EXTRACT(HOUR FROM ended_at) as hour_ended,
  TIMESTAMP_DIFF(ended_at, started_at, HOUR) as time_difference,
  
  COUNT(*) as total_rides
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY 
  started_at,
  ended_at,
  rider,
  hour_started,
  hour_ended,
  time_difference
ORDER BY
  time_difference DESC;



-- rides and their time difference in minutes
SELECT
  rider,
  started_at,
  ended_at,
  EXTRACT(MINUTE FROM started_at) as min_started,
  EXTRACT(MINUTE FROM ended_at) as min_ended,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) as time_difference,
  
  COUNT(*) as total_rides
FROM
  upbeat-task-436721-c5.bike_share.bike_share_data
GROUP BY 
  started_at,
  ended_at,
  rider,
  min_started,
  min_ended,
  time_difference
ORDER BY
  time_difference DESC;


#GIVES YOU THE MOST POPULAR END_STATION_NAME FOR MEMBER
SELECT 
  end_station_name,
  ROUND(AVG(end_lat),5) AS end_lat,
  ROUND(AVG(end_lng),5) AS end_lng, 
  COUNT(end_station_name) AS end_station_count
FROM 
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'member'
GROUP BY 
  end_station_name
ORDER BY 
  COUNT(end_station_name) DESC;


#GIVES YOU THE MOST POPULAR END_STATION_NAME FOR CASUAL
SELECT 
  end_station_name,
  ROUND(AVG(end_lat),5) AS end_lat,
  ROUND(AVG(end_lng),5) AS end_lng, 
  COUNT(end_station_name) AS end_station_count
FROM 
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'casual'
GROUP BY 
  end_station_name
ORDER BY 
  COUNT(end_station_name) DESC;

#GIVES YOU THE MOST POPULAR START_STATION_NAME FOR MEMBER
SELECT 
  start_station_name,
  ROUND(AVG(start_lat),5) AS start_lat,
  ROUND(AVG(start_lng),5) AS start_lng, 
  COUNT(start_station_name) AS start_station_count
FROM 
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'member'
GROUP BY 
  start_station_name
ORDER BY 
  COUNT(start_station_name) DESC;


#GIVES YOU THE MOST POPULAR START_STATION_NAME FOR CASUAL
SELECT 
  start_station_name,
  ROUND(AVG(start_lat),5) AS start_lat,
  ROUND(AVG(start_lng),5) AS start_lng, 
  COUNT(start_station_name) AS start_station_count
FROM 
  upbeat-task-436721-c5.bike_share.bike_share_data
WHERE 
  rider = 'casual'
GROUP BY 
  start_station_name
ORDER BY 
  COUNT(start_station_name) DESC;


select * from `upbeat-task-436721-c5.bike_share.bike_share_data` 









