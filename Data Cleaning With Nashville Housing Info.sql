--Data Cleaning with Nashville Housing data

SELECT * FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------
--Standardize Date Format (datetime to date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate); --store converted sale date into new table

SELECT SaleDateConverted, CONVERT(Date,SaleDate) FROM PortfolioProject.dbo.NashvilleHousing --check



------------------------------------------------------------------------------------------------------------------
--Populate Property Address data
--(observe data and find that when 2 different rows have same ParcelID then they have same PropertyAddress)

SELECT * FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --if a.prop is null then replace with b.prop
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]!=b.[UniqueID ] --don't want to use same rows
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]!=b.[UniqueID ] 
WHERE a.PropertyAddress IS NULL



------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns using Substrings (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address --CHARINDEX returns number position so -1 to delete ,
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 
ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1); --store Address into new PropertySplitAddress table
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)); --store city into new PropertySplitCity table

--CHECK
SELECT PropertySplitAddress,PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------------------
--Breaking out OwnerAddress into Individual Columns using PARSENAME (Address, City, State)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),--need to replace ',' with '.' to use PARSENAME
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

--STORE OwnerAddress INTO NEW TABLES
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3); 
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2); 
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1); 

--CHECK
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 --CHECK

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	  WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END



------------------------------------------------------------------------------------------------------------------
--Remove Duplicates using CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,--partition on things that should be unique to each row
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID ) row_num							
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE FROM RowNumCTE
WHERE row_num >1 

--SELECT * FROM RowNumCTE
--WHERE row_num >1 
--ORDER BY PropertyAddress --104 duplicate rows deleted



------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
