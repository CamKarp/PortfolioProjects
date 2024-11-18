--CHECK DATA


SELECT *
FROM PORTFOLIO.dbo.NashvilleHousing


--STANDARDIZE DATE FORMATTING


SELECT SaleDateConverted, CONVERT(DATE,Saledate)
FROM PORTFOLIO.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)


--POPULATING ADDRESS NULLS


SELECT NA.ParcelID, NA.PropertyAddress, NB.ParcelID, NB.PropertyAddress, ISNULL(NA.PropertyAddress, NB.PropertyAddress)
FROM PORTFOLIO.dbo.NashvilleHousing NA
JOIN PORTFOLIO.dbo.NashvilleHousing NB
ON NA.ParcelID = NB.ParcelID
AND NA.[UniqueID] <> NB.[UniqueID]
WHERE NA.PropertyAddress is NULL

UPDATE NA
SET PropertyAddress = ISNULL(NA.PropertyAddress, NB.PropertyAddress)
FROM PORTFOLIO.dbo.NashvilleHousing NA
JOIN PORTFOLIO.dbo.NashvilleHousing NB
ON NA.ParcelID = NB.ParcelID
AND NA.[UniqueID] <> NB.[UniqueID]
WHERE NA.PropertyAddress is NULL


--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) w/ SUBSTRING


SELECT PropertyAddress
FROM PORTFOLIO.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM PORTFOLIO.dbo.NashvilleHousing


-- (New Columns)


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) w/ PARSENAME

SELECT *
FROM PORTFOLIO.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PORTFOLIO.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PORTFOLIO.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PORTFOLIO.dbo.NashvilleHousing


--CHANGING "SoldAsVacant" FIELD PARAMETER FROM Y/N to Yes/No

SELECT DISTINCT(SoldAsVacant)
FROM PORTFOLIO.dbo.NashvilleHousing


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PORTFOLIO.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				        WHEN SoldAsVacant = 'N' THEN 'No'
				        ELSE SoldAsVacant
				        END


-- DELETE UNUSED COLUMNS


SELECT *
FROM PORTFOLIO.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
