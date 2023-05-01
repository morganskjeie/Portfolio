/* Cleaning Data in SQL Queries */

--Populate Poperty Address Data

SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
    FROM Portfolio..NHousing AS a
    JOIN Portfolio..NHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NHousing AS a
    JOIN Portfolio..NHousing AS b
        ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress IS NULL

--Separate Address into Separate Columns

SELECT PropertyAddress
    FROM Portfolio..NHousing

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
    FROM Portfolio..NHousing

ALTER TABLE NHousing
ADD PropertySplitAddress NVARCHAR(500);

UPDATE NHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE NHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT OwnerAddress FROM Portfolio..NHousing

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM Portfolio..NHousing

ALTER TABLE NHousing
ADD OwnerSplitAddress NVARCHAR(500);

UPDATE NHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NHousing
ADD OwnerSplitState NVARCHAR(50);

UPDATE NHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM Portfolio..NHousing

--Remove Duplicates

WITH RowNumberCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY    ParcelID,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY UniqueID) AS row_number
FROM Portfolio..NHousing)

DELETE FROM RowNumberCTE
WHERE row_number > 1

SELECT * FROM RowNumberCTE
WHERE row_number >1

--Delete Unused Columns

SELECT * FROM Portfolio..NHousing

ALTER TABLE Portfolio..NHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict