Select top 100 * from Progetti.dbo.NashvilleHousing;
--Convert date to standard format.

ALTER TABLE Progetti.dbo.NashvilleHousing
ADD ConvertedDate Date;

UPDATE Progetti.dbo.NashvilleHousing
SET ConvertedDate = CONVERT(Date, SaleDate);

--Research and fill where Property Address is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Progetti.dbo.NashvilleHousing a
JOIN Progetti.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Progetti.dbo.NashvilleHousing a
JOIN Progetti.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Split PropertyAddress Column definining separately address and city

ALTER TABLE Progetti.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
From Progetti.dbo.NashvilleHousing;

UPDATE Progetti.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE Progetti.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Progetti.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

--Split OwnerAddress Column, separating address, city and state

ALTER TABLE Progetti.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
from Progetti.dbo.NashvilleHousing;

Update Progetti.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Progetti.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
from Progetti.dbo.NashvilleHousing;

UPDATE Progetti.dbo.NashvilleHousing
SET OwnerSplitCIty = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE Progetti.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from Progetti.dbo.NashvilleHousing;

UPDATE Progetti.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From Progetti.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

UPDATE Progetti.dbo.NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

--Remove duplicates

WITH NumbR AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Progetti.dbo.NashvilleHousing
)
Select *
From NumbR
Where row_num > 1
Order by PropertyAddress;

WITH NumbR as (
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num

FROM Progetti.dbo.NashvilleHousing
)
DELETE
From NumbR
where row_num > 1;

--Remove useless columns

ALTER TABLE Progetti.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE Progetti.dbo.NashvilleHousing
DROP COLUMN SaleDate;