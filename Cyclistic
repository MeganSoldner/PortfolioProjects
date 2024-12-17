--------------------------------------------------------------------------------
--Cyclistic Data


--Joining data from march 2023 to feb 2024 into one table using UNION ALL
--new Cyclistic_Mar2023_Feb2024 table has 5,707,168 rows
--SELECT *
--INTO Cyclistic_Mar2023_Feb2024
--FROM dbo.Mar2023
--UNION ALL
--SELECT * FROM dbo.Apr2023
--UNION ALL
--SELECT * FROM dbo.May2023
--UNION ALL
--SELECT * FROM dbo.Jun2023
--UNION ALL
--SELECT * FROM dbo.Jul2023
--UNION ALL
--SELECT * FROM dbo.Aug2023
--UNION ALL
--SELECT * FROM dbo.Sep2023
--UNION ALL
--SELECT * FROM dbo.Oct2023
--UNION ALL
--SELECT * FROM dbo.Nov2023
--UNION ALL
--SELECT * FROM dbo.Dec2023
--UNION ALL
--SELECT * FROM dbo.Jan2024
--UNION ALL
--SELECT * FROM dbo.Feb2024;




--------------------------------------------------------------------------------
--DATA CLEANING

--ADDING COLUMNS ride_length, day_of_week, ride_month
--DELETING nulls and rows where values dont make sense 
--(ride_length less than or equal to zero, ride_length greater than a day)
--start_station_name and end_station_name should not be null so delete rows with it


--checking for duplicates with unique ride_id
--no duplicates found
--SELECT ride_id, count(*) AS Count
--FROM dbo.Cyclistic_Mar2023_Feb2024
--GROUP BY ride_id
--HAVING count(*) > 1
--;

--Add ride_length column in minutes
ALTER TABLE dbo.Cyclistic_Mar2023_Feb2024
ADD ride_length AS DATEDIFF(MINUTE, started_at, ended_at);

--Add day_of_week column
--1=Sunday, 2=Monday, ... , 7=Saturday
ALTER TABLE dbo.Cyclistic_Mar2023_Feb2024
ADD day_of_week AS DATEPART(WEEKDAY, started_at);

--Add ride_month column
--1=Jan, 2=Feb, ... 12=Dec
ALTER TABLE dbo.Cyclistic_Mar2023_Feb2024
ADD ride_month AS MONTH(started_at);

--ride_length should be greater than 0
--a Cyclistic Employee may have taken a bike out for a quick inspection/ maintence 
--a member may have decided they dont want to take a bike out for a ride and put it back
--data entry errors may have occured
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE ride_length <= 0; --86,179 rows are less than or equal to 0
----
DELETE FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE ride_length <= 0;
--NEW TOTAL ROWs IS 5,620,989

--start_station_name or start_station_id should not be null so we can find where the bike ride began
--delete rows where both are null
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE start_station_name IS NULL AND start_station_id IS NULL;
----
DELETE FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE start_station_name IS NULL AND start_station_id IS NULL;
--new total rows 4779614

--end_station_name or end_station_id should not be null so we can find where the bike ride ended
--delete rows where both are null
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE end_station_name IS NULL AND end_station_id IS NULL;
----
DELETE FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE end_station_name IS NULL AND end_station_id IS NULL;
--new total rows 4282684

--rides that are longer than a day could skew the results
--maybe a bike wasnt returned to a dock
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE ride_length > 1440 --(60*24) greater than a day
----
DELETE FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE ride_length > 1440;
--NEW TOTAL Rows IS 4282534

--CHECK the ride times started before they ended
SELECT started_at, ended_at
FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE ended_at < started_at

--CHECK that the dates our within the givin data
--mar 2023 to feb 2024
--the results started within the given dates but ended the day after so we will keep them
SELECT * 
FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE CAST(started_at AS DATE) >= '2024-03-01' OR CAST(started_at AS DATE) <= '2023-02-28'
	OR CAST(ended_at AS DATE) >= '2024-03-01' OR CAST(ended_at AS DATE) <= '2023-02-28';



--
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE member_casual = 'casual' AND CAST(started_at AS TIME) !>'00:00:00' AND  CAST(started_at AS TIME) !< '18:00:00';


--------------------------------------------------------------------------------
--ANALYSIS

--1
--total rides members vs casual members
SELECT member_casual, COUNT(*) AS total_rides
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual;

--2
--total minutes members vs casual members
SELECT member_casual, SUM(ride_length) AS total_ride_time
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual;

--3
--total rides per type per member
SELECT member_casual, rideable_type,COUNT(*) AS total_rides
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual, rideable_type;

--4
--total ride time per ride type per member
SELECT member_casual, rideable_type,SUM(ride_length) AS total_ride_time
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual, rideable_type
ORDER BY total_ride_time;

--find smallest date and most recent date
--SELECT CAST(started_at AS DATE) AS date_only
--FROM dbo.Cyclistic_Mar2023_Feb2024
--ORDER BY date_only DESC --MIN 2023-03-01 MAX 2024-02-29

--5
--Average start times for m vs. c
--converts to seconds, gets avg of seconds, uses '2023-01-01' as reference to convert to datetime with new avg seconds as actual time, returns overall avg start time 
SELECT member_casual, CONVERT(TIME(0), DATEADD(SECOND, AVG(CAST(DATEDIFF(SECOND, '2023-01-01', started_at) AS BIGINT)), '2023-01-01')) AS Avg_start_time
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual
;--cas 01:41:56.000 pm  mem 11:37:07.000 am

--6
--Avg ride length
SELECT member_casual,AVG(ride_length) AS mean_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual;

--7
--max ride length
SELECT member_casual,MAX(ride_length) AS Max_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual;

--8
--min ride length
SELECT member_casual,Min(ride_length) AS Min_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual;

--9
--total rides per day_of_week
SELECT member_casual, day_of_week, COUNT(*) AS total_rides_per_day
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY day_of_week, member_casual
ORDER BY day_of_week

--member mode of day_of_week
WITH MemberTotalRides AS (
	SELECT day_of_week, COUNT(*) AS total_rides
	FROM dbo.Cyclistic_Mar2023_Feb2024
	WHERE member_casual = 'member'
	GROUP BY day_of_week
),
maxRides AS (
	SELECT MAX(total_rides) as mode
	FROM MemberTotalRides
)
select day_of_week FROM MemberTotalRides
WHERE total_rides = (SELECT mode FROM maxRides) 

--casual mode of day_of_week
WITH CasualTotalRides AS (
	SELECT day_of_week, COUNT(*) AS total_rides
	FROM dbo.Cyclistic_Mar2023_Feb2024
	WHERE member_casual = 'casual'
	GROUP BY day_of_week
),
maxRides AS (
	SELECT MAX(total_rides) as mode
	FROM CasualTotalRides
)
select day_of_week FROM CasualTotalRides
WHERE total_rides = (SELECT mode FROM maxRides) 


--ride lengths per member per day_of_week
SELECT member_casual, day_of_week, SUM(ride_length) AS total_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;

--10
--ride COUNT per member type per day_of_week
SELECT member_casual, day_of_week, COUNT(*) AS total_rides
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;

--11
--avg ride time per member by day of week
SELECT member_casual, day_of_week, AVG(ride_length) as avg_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual, day_of_week
ORDER BY day_of_week


--avg ride length per all members by day of week
SELECT day_of_week, AVG(ride_length) AS avg_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY day_of_week
ORDER BY day_of_week;

--12
--total rides per member per ride_month
SELECT member_casual, ride_month, COUNT(*) AS total_rides_per_month
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY ride_month, member_casual
ORDER BY ride_month;

--13
--avg ride time per member by day of week
SELECT member_casual, ride_month, AVG(ride_length) as avg_ride_length
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual, ride_month
ORDER BY ride_month


--top 10 most popular start stations
SELECT TOP 10
	start_station_name, COUNT(*) AS num_trips_from_start_station
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY start_station_name
ORDER BY COUNT(*) DESC;

--start station trips
SELECT start_station_name, COUNT(*) AS num_trips_from_start_station
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY start_station_name
ORDER BY COUNT(*) DESC;

--top 10 most popular end stations
SELECT TOP 10
	end_station_name, COUNT(*) AS num_trips_to_end_station
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY end_station_name
ORDER BY COUNT(*) DESC;

--end station trips
SELECT end_station_name, COUNT(*) AS num_trips_to_end_station
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY end_station_name
ORDER BY COUNT(*) DESC;


--skew in data when grouped by march the avg ride data seems lower than it should be
SELECT MONTH(started_at), COUNT(*) AS mon_count
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY MONTH(started_at)
ORDER BY mon_count DESC

SELECT MONTH(started_at), COUNT(*) AS mon_count, avg(ride_length) as avg_ride_len, MEDIAN(ride_length)
FROM dbo.Cyclistic_Mar2023_Feb2024
WHERE member_casual = 'casual'
GROUP BY MONTH(started_at)
ORDER BY MONTH(started_at)

--5
--Average start times for m vs. c
--converts to seconds, gets avg of seconds, uses '2023-01-01' as reference to convert to datetime with new avg seconds as actual time, returns overall avg start time 
SELECT member_casual, DATEPART(WEEKDAY, started_at) as Daynum, CONVERT(TIME(0), DATEADD(SECOND, AVG(CAST(DATEDIFF(SECOND, '2023-01-01', started_at) AS BIGINT)), '2023-01-01')) AS Avg_start_time
FROM dbo.Cyclistic_Mar2023_Feb2024
GROUP BY member_casual, DATEPART(WEEKDAY, started_at)
ORDER BY Daynum
;--cas 01:41:56.000 pm  mem 11:37:07.000 am

WITH SortedData AS (
    SELECT
		member_casual,
        ride_length,
        MONTH(started_at) AS RideMonth,  -- Extract month from started_at
        ROW_NUMBER() OVER (PARTITION BY member_casual, MONTH(started_at) ORDER BY ride_length) AS RowNum,
        COUNT(*) OVER (PARTITION BY member_casual, MONTH(started_at)) AS TotalRows
    FROM dbo.Cyclistic_Mar2023_Feb2024
	WHERE ride_length IS NOT NULL 
)
SELECT
	member_casual,
    RideMonth,
	AVG(ride_length) AS avgRideLength,
    CASE
        WHEN TotalRows % 2 = 1 THEN
            -- If the number of rows is odd, pick the middle row
            MAX(CASE WHEN RowNum = (TotalRows + 1) / 2 THEN ride_length END)
        ELSE
            -- If the number of rows is even, calculate the average of the two middle rows
            AVG(CASE 
                    WHEN RowNum IN (TotalRows / 2, TotalRows / 2 + 1) THEN ride_length 
                    ELSE NULL 
                END)
    END AS MedianRideLength
FROM SortedData
GROUP BY member_casual, RideMonth, TotalRows
ORDER BY RideMonth;



--checking for errors
--i think using avg makes more sense since we are looking at rides taken within a day
WITH SortedData AS (
    SELECT
        ride_length,
        member_casual,  -- Include memberType to partition by
        MONTH(started_at) AS RideMonth,  -- Extract the month from started_at
        ROW_NUMBER() OVER (PARTITION BY member_casual, MONTH(started_at) ORDER BY ride_length) AS RowNum,
        COUNT(*) OVER (PARTITION BY member_casual, MONTH(started_at)) AS TotalRows
    FROM dbo.Cyclistic_Mar2023_Feb2024
    WHERE ride_length IS NOT NULL  -- Exclude NULL ride_lengths from consideration
)
-- Check row counts and partitioning
SELECT 
    member_casual,
    RideMonth,
    TotalRows,
    COUNT(*) AS RowsInGroup,
    MAX(ride_length) AS MaxRideLength,
    MIN(ride_length) AS MinRideLength
FROM SortedData
GROUP BY member_casual, RideMonth, TotalRows
ORDER BY member_casual, RideMonth;
















--------------------------
SELECT TOP(10)*
FROM dbo.Cyclistic_Mar2023_Feb2024 
;
SELECT * FROM dbo.Cyclistic_Mar2023_Feb2024

