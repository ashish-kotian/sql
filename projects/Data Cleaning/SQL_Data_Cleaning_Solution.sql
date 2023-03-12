SELECT *
FROM [Housing Database]..['Raw Data$']

--Standardize date format 

SELECT SaleDate
, CONVERT (Date, SaleDate)
FROM [Housing Database]..['Raw Data$']

ALTER TABLE [Housing Database]..['Raw Data$']
ADD SaleDateUpdated Date

UPDATE [Housing Database]..['Raw Data$']
SET SaleDateUpdated = CONVERT (Date, SaleDate)


--Populate Property Address

SELECT a.[UniqueID ]
, a.ParcelID
, a.PropertyAddress
, b.[UniqueID ]
, b.ParcelID
, b.PropertyAddress
FROM [Housing Database]..['Raw Data$'] a
JOIN [Housing Database]..['Raw Data$'] b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE b.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Housing Database]..['Raw Data$'] a
JOIN [Housing Database]..['Raw Data$'] b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking Address into individual columns (Adress, City, State)


 SELECT PropertyAddress
 , SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM [Housing Database]..['Raw Data$']

ALTER TABLE [Housing Database]..['Raw Data$']
ADD PropertyAddressUpdate NVarchar(250)

UPDATE [Housing Database]..['Raw Data$']
SET PropertyAddressUpdate = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Housing Database]..['Raw Data$']
ADD PropertyAddressCity NVarchar(250)

UPDATE [Housing Database]..['Raw Data$']
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress
, PropertyAddressUpdate
, PropertyAddressCity
FROM [Housing Database]..['Raw Data$']


SELECT OwnerAddress
 , PARSENAME(REPLACE(OwnerAddress,',','.'),3)
 , PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 , PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Housing Database]..['Raw Data$']

ALTER TABLE [Housing Database]..['Raw Data$']
ADD OwnerCity NVarchar(250)

UPDATE [Housing Database]..['Raw Data$']
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Housing Database]..['Raw Data$']
ADD OwnerState NVarchar(250)

UPDATE [Housing Database]..['Raw Data$']
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE [Housing Database]..['Raw Data$']
ADD OwnerSplitAddress NVarchar(250)

UPDATE [Housing Database]..['Raw Data$']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

SELECT OwnerState
, OwnerCity
, OwnerSplitAddress
FROM [Housing Database]..['Raw Data$']

--Change Y and N to Yes and No 

SELECT DISTINCT(SoldAsVacant)
, CASE
   WHEN SoldAsVacant = 'N' THEN 'No'
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   ELSE SoldAsVacant
   END
FROM [Housing Database]..['Raw Data$']

UPDATE [Housing Database]..['Raw Data$']
SET SoldAsVacant = CASE
   WHEN SoldAsVacant = 'N' THEN 'No'
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   ELSE SoldAsVacant
   END
FROM [Housing Database]..['Raw Data$']


SELECT DISTINCT(SoldAsVacant)
FROM [Housing Database]..['Raw Data$']

--Remove Duplicates

WITH CTE As
(SELECT Uniqueid, ParcelID
,Row_Number() Over (Partition By
 Parcelid
, saledate
, saleprice
, LegalReference
ORDER BY UniqueID) AS Row_Num
FROM [Housing Database]..['Raw Data$'])

SELECT *
FROM CTE
--WHERE Row_Num > 1
WHERE Row_Num != '2'
AND Row_Num != '3'



