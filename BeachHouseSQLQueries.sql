--BEACH HOUSE DATA EXPLORATION
SELECT * FROM BeachHouses
SELECT * FROM BeachCosts;
SELECT * FROM BeachInfo;



-------------------------------------------------------------------------------
--DATA CLEANING
--getting rid of null rows and fixing date format
DELETE FROM BeachCosts
WHERE Name IS NULL;

ALTER TABLE BeachCosts
DROP COLUMN Dates;

ALTER TABLE BeachCosts
ADD Dates2 Date;

UPDATE BeachCosts
SET Dates2 = CONVERT(Date,Dates);--renamed at Dates


--Populate '#' data Where NULL
--(observe data and find that when 2 different rows have same Name then they have same #)
SELECT a.Name, a.#,b.Name,b.#, ISNULL(a.#, b.#) --if a.# is null then replace with b.#
FROM BeachHouses a
JOIN BeachHouses b
ON a.Name = b.Name AND a.[Dates] != b.[Dates]
WHERE a.# IS NULL

UPDATE a
SET # = ISNULL(a.#, b.#)
FROM PortfolioProject.dbo.BeachHouses a
JOIN PortfolioProject.dbo.BeachHouses b
ON a.Name = b.Name
AND a.[Dates]!=b.[Dates] 
WHERE a.# IS NULL


--Pelican's Perch Missing #
UPDATE PortfolioProject.dbo.BeachHouses
SET # = '#19'
WHERE # = '19'


--Populate Town data Where NULL
--(observe data and find that when 2 different rows have same Name then they have same Town)
SELECT a.Name, a.Town,b.Name,b.Town, ISNULL(a.Town, b.Town) --if a.# is null then replace with b.#
FROM BeachHouses a
JOIN BeachHouses b
ON a.Name = b.Name AND a.[Dates] != b.[Dates]
WHERE a.Town IS NULL


UPDATE a
SET Town = ISNULL(a.Town, b.Town)
FROM PortfolioProject.dbo.BeachHouses a
JOIN PortfolioProject.dbo.BeachHouses b
ON a.Name = b.Name
AND a.[Dates]!=b.[Dates] 
WHERE a.Town IS NULL


-------------------------------------------------------------------------------
--Add Cost per person column
ALTER TABLE BeachHouses
ADD CostPerPerson money;

UPDATE BeachHouses
SET CostPerPerson = PriceWithoutDogs/10


-------------------------------------------------------------------------------
--Add bathrooms vs. half baths column instead of just bathrooms
ALTER TABLE BeachHouses
ADD FullBathrooms nvarchar(255);
ALTER TABLE BeachHouses
ADD HalfBathrooms nvarchar(255);


--fix how data was input
UPDATE BeachHouses
SET Bathrooms = '5-1'
WHERE Name = 'Doc Holiday';

--SELECT PARSENAME(REPLACE(Bathrooms,'-','.'),2) FROM PortfolioProject.dbo.BeachHouses -- number of full bathrooms
--SELECT PARSENAME(REPLACE(Bathrooms,'-','.'),1) FROM PortfolioProject.dbo.BeachHouses -- number of half bathrooms

UPDATE BeachHouses
SET FullBathrooms = PARSENAME(REPLACE(Bathrooms,'-','.'),2);
UPDATE BeachHouses
SET HalfBathrooms = PARSENAME(REPLACE(Bathrooms,'-','.'),1);



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--split BeachHouses table into
--BeachCosts and BeachInfo in google sheets
--then loaded in new tables



-------------------------------------------------------------------------------
--Compare Prices

--ALL cost info
SELECT Name, Dates, ActualPrice AS Total, PriceWithoutDogs AS TotalWithoutDogs, CostPerPerson 
FROM BeachCosts
ORDER BY CostPerPerson;

--focus on price per person at location on certain date
SELECT Name, Dates, CostPerPerson 
FROM BeachCosts
ORDER BY CostPerPerson;

--people want to pay less than 700 if possible
--set budget to 700
SELECT Name, Dates, CostPerPerson 
FROM BeachCosts
WHERE CostPerPerson <= 700
ORDER BY CostPerPerson;



-------------------------------------------------------------------------------
--Amenities

--ALL beach house information
SELECT * FROM BeachInfo

--WANTS:
--at least 5 bedrooms, hotTub, oceanfront, at least 4 full bathrooms, at least two dogs
SELECT Name, Bedrooms, HotTub, OceanLocation, FullBathrooms, PetPolicy FROM BeachInfo
WHERE Bedrooms >= 5
AND HotTub = 'Yes' 
AND OceanLocation = 'Oceanfront' 
AND FullBathrooms >= 4
AND PetPolicy LIKE '%2%';

--Compare these 'Wants' with week and price
SELECT info.Name, Dates, CostPerPerson, Bedrooms, HotTub, OceanLocation, FullBathrooms, PetPolicy FROM BeachInfo info
JOIN BeachCosts cost
ON info.Name = cost.Name
WHERE HotTub = 'Yes' 
AND OceanLocation = 'Oceanfront' 
AND FullBathrooms >= 4
AND PetPolicy LIKE '%2%'
ORDER BY CostPerPerson;



-------------------------------------------------------------------------------
--Beach Houses that meet amenity requirments and are in budget

SELECT info.name, Dates, CostPerPerson, #, Town, OceanLocation, PrivatePool, HotTub, PetPolicy, Bedrooms,extras,HalfBathrooms,FullBathrooms FROM BeachInfo info
JOIN BeachCosts cost
ON info.Name = cost.Name
WHERE HotTub = 'Yes' 
AND OceanLocation = 'Oceanfront' 
AND FullBathrooms >= 4
AND PetPolicy LIKE '%2%'
AND CostPerPerson <=700
ORDER BY CostPerPerson;