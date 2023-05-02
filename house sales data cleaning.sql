-- CLEANING DATA IN SQL

SELECT * 
FROM portfolio.dbo.NationalHousing

------------------------------------------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(date, SaleDate) 
FROM portfolio.dbo.NationalHousing

------------------------------------------------------------------------------------------------------------------------------------------

--ADDING CHANGES IN DATASET

UPDATE NationalHousing
SET SaleDate=CONVERT(date, SaleDate) -- THIS METHOD NOT WORKING CURRENTLY

ALTER TABLE NationalHousing
add SaleDateConverted Date;

UPDATE NationalHousing
SET SaleDateConverted=CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------

--POPULATED PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM portfolio.dbo.NationalHousing
--Where PropertyAddress is Null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.NationalHousing a
JOIN portfolio.dbo.NationalHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.NationalHousing a
JOIN portfolio.dbo.NationalHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM portfolio.dbo.NationalHousing
--Where PropertyAddress is Null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM portfolio.dbo.NationalHousing

ALTER TABLE NationalHousing
add PropertySplitAddress Nvarchar(255);

UPDATE NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NationalHousing
add PropertySplitCity Nvarchar(255);

UPDATE NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM portfolio.dbo.NationalHousing



SELECT OwnerAddress 
FROM portfolio.dbo.NationalHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress ,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress ,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress ,',', '.'), 1)
FROM portfolio.dbo.NationalHousing

ALTER TABLE NationalHousing
add OwnerSplitAddress Nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 3)

ALTER TABLE NationalHousing
add OwnerSplitCity Nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 2)

ALTER TABLE NationalHousing
add OwnerSplitState Nvarchar(255);

UPDATE NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 1)

SELECT * 
FROM portfolio.dbo.NationalHousing

------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to 'YES' and 'NO' in 'Sold in vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio.dbo.NationalHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolio.dbo.NationalHousing


Update NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

With RowNumCTE as(
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
FROM portfolio.dbo.NationalHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
WHERE row_num>1
--order by PropertyAddress

SELECT * 
FROM portfolio.dbo.NationalHousing

------------------------------------------------------------------------------------------------------------------------------------------

--DELETE Unused coloumns

SELECT * 
FROM portfolio.dbo.NationalHousing

ALTER TABLE portfolio.dbo.NationalHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress