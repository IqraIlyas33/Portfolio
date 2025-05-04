SELECT *
From iqradb.dbo.[NashvilleHousing]

-- Populate Property Address Data
Select *
From iqradb.dbo.[NashvilleHousing]
WHERE [NashvilleHousing].PropertyAddress is NULL

Select a.parcelid, a.PropertyAddress, b.parcelid, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From iqradb.dbo.[NashvilleHousing] as a
JOIN iqradb.dbo.[NashvilleHousing] as b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From iqradb.dbo.[NashvilleHousing] as a
JOIN iqradb.dbo.[NashvilleHousing] as b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.PropertyAddress is NULL

-- Breaking out Address Into Individual Column (address, city and State)
SELECT propertyaddress
from iqradb.dbo.[NashvilleHousing]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM iqradb.dbo.[NashvilleHousing]

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update iqradb.dbo.[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add PropertySplitCity Nvarchar (255);

Update iqradb.dbo.[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM iqradb.dbo.[NashvilleHousing]

SELECT OwnerAddress
FROM iqradb.dbo.[NashvilleHousing]

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM iqradb.dbo.[NashvilleHousing]

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update iqradb.dbo.[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add OwnerSplitCity Nvarchar (255);

Update iqradb.dbo.[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add OwnerSplitState Nvarchar (255);

Update iqradb.dbo.[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM iqradb.dbo.[NashvilleHousing]

-- Change 1 and 0 to Yes and No in "Sold as Vacant" Field
SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM iqradb.dbo.[NashvilleHousing]
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
       CASE 
           WHEN CAST(SoldAsVacant AS VARCHAR) = '1' THEN 'YES'
           WHEN CAST(SoldAsVacant AS VARCHAR) = '0' THEN 'NO'
           ELSE CAST(SoldAsVacant AS VARCHAR)
       END
FROM iqradb.dbo.[NashvilleHousing]

ALTER TABLE iqradb.dbo.[NashvilleHousing]
Add SoldAsVacantStatus Nvarchar (255); -- Add a new column

Update iqradb.dbo.[NashvilleHousing] --Updating the table
SET SoldAsVacantStatus = CASE 
           WHEN CAST(SoldAsVacant AS VARCHAR) = '1' THEN 'YES'
           WHEN CAST(SoldAsVacant AS VARCHAR) = '0' THEN 'NO'
           ELSE CAST(SoldAsVacant AS VARCHAR)
       END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM iqradb.dbo.[NashvilleHousing] 
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num >1
--ORDER BY PropertyAddress


-- DELETE UNUSED COLUMNS

select *
FROM iqradb.dbo.[NashvilleHousing] 

ALTER TABLE iqradb.dbo.[NashvilleHousing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
