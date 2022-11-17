/*
Data Cleaning in SQL Queries
*/

SELECT *
FROM dbo.NashvilleHousing

-- Convert SaleDate column from datetime to date

SELECT SaleDate, CONVERT(date, SaleDate)
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)
--OR
ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted date

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Fill in NULL values in PropertyAddress column
-- ParcelID indicates PropertyAddress even though different UniqueID

SELECT *
FROM dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT A.UniqueID, A.ParcelID, A.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress),
	   B.UniqueID, B.ParcelID, B.PropertyAddress
FROM dbo.NashvilleHousing as A
JOIN dbo.NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM dbo.NashvilleHousing as A
JOIN dbo.NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City)
-- PropertyAddress

SELECT PropertyAddress,
	   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM dbo.NashvilleHousing
--------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
-------------------------------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
-----------------------------------------------------------------------------------------------------------

SELECT *
FROM dbo.NashvilleHousing

-- Breaking out Address into Individual Columns (Address, City, State)
-- OwnerAddress
-- PARSENAME only look for '.', replace ',' with '.'

SELECT OwnerAddress,
	   PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3) as Address,
	   PARSENAME (REPLACE(OwnerAddress, ',', '.') , 2) as City,
	   PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM dbo.NashvilleHousing
--------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 3)
-----------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 2)
--------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.') , 1)
---------------------------------------------------------------------

SELECT *
FROM dbo.NashvilleHousing

-- Change "Y" and "N" to "Yes" and "No" in SoldasVacant column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	   CASE
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE
				   WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Delete Duplicate
-- PARTITION BY(Unique values to each row)
-- Assume UniqueID not valid to be use as Unique Identifier

WITH RowNumCTE as (
SELECT *,
	   ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY UniqueID)
		as row_num
FROM dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Column(s)

SELECT *
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate