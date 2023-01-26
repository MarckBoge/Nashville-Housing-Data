/* DATA CLEANING SQL QUERIES of the Nashville Housing Dataset*/
-- This is a Case study focus on data cleaning using SQL
-- The dataset is available on https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

SELECT *
FROM NashvilleHousingData

-- Populate Property Address Data --

SELECT PropertyAddress
FROM NashvilleHousingData
WHERE PropertyAddress is null

SELECT *
FROM NashvilleHousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------
-- Breaking out Address into induvidual columns (Address, City, State)

Select PropertyAddress
From NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1) as Address
FROM NashvilleHousingData;

SELECT
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
FROM NashvilleHousingData;

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress varchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity varchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 , LENGTH(PropertyAddress))

SELECT *
FROM NashvilleHousingData

SELECT OwnerAddress
FROM NashvilleHousingData

SELECT SPLIT_PART(OwnerAddress, ',', 1),
SPLIT_PART(OwnerAddress, ',', 2),
SPLIT_PART(OwnerAddress, ',', 3)
FROM NashvilleHousingData; 

ALTER TABLE NashvilleHousingData
ADD OwnSplitAddress varchar(255);

UPDATE NashvilleHousingData
SET OwnSplitAddress = SPLIT_PART(OwnerAddress, ',', 1)

ALTER TABLE NashvilleHousingData
ADD OwnSplitCity varchar(255);

UPDATE NashvilleHousingData
SET OwnSplitCity = SPLIT_PART(OwnerAddress, ',', 2)

ALTER TABLE NashvilleHousingData
ADD OwnSplitState varchar(255);

UPDATE NashvilleHousingData
SET OwnSplitState = SPLIT_PART(OwnerAddress, ',', 3)

SELECT *
FROM NashvilleHousingData
ORDER BY PropertySplitCity


---------------------------------------------------------------
--- Change Y and N to Yes and No in "Sold as Vacant" field  ---


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;
	 
---------------------------------------------------------------
--- Locate Duplicates  ---

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			 	PropertyAddress,
		     	SalePrice,
				SaleDate,
		     	LegalReference
			 	ORDER BY
			 	UniqueID
			 	) row_num
	
FROM NashvilleHousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------
-- Remove Duplicates --

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			 	PropertyAddress,
		     	SalePrice,
				SaleDate,
		     	LegalReference
			 	ORDER BY
			 	UniqueID
			 	) row_num
	
FROM NashvilleHousingData
--ORDER BY ParcelID
)
DELETE FROM NashvilleHousingData
WHERE (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID) IN 
    (SELECT ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, UniqueID
    FROM RowNumCTE
    WHERE row_num > 1)


SELECT *
FROM NashvilleHousingData


---------------------------------------------------------------
-- Remove Unused Columns --

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress;

SELECT *
FROM NashvilleHousingData

