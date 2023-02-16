SELECT * FROM BeachCosts;
SELECT * FROM BeachInfo;

--getting rid of null rows and fixing date format
DELETE FROM BeachCosts
WHERE Name IS NULL;

ALTER TABLE BeachCosts
DROP COLUMN Dates;

ALTER TABLE BeachCosts
ADD Dates2 Date;

UPDATE BeachCosts
SET Dates2 = CONVERT(Date,Dates);--renamed at Dates


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

