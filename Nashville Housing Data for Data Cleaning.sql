/*

Cleaning Data in SQL Queries

*/

Select *
From [Nashville Housing Data For data cleaning v1]

-- Standardize Data Format

Select SaleDateConverted
From [Nashville Housing Data For data cleaning v1]

Update [Nashville Housing Data For data cleaning v1]
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add SaleDateConverted Date;

Update [Nashville Housing Data For data cleaning v1]
Set SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address Data

Select *
From [Nashville Housing Data For data cleaning v1]
--where PropertyAddress is null 
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
From [Nashville Housing Data For data cleaning v1] a
Join [Nashville Housing Data For data cleaning v1] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
--Where a.PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
From [Nashville Housing Data For data cleaning v1] a
Join [Nashville Housing Data For data cleaning v1] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
From [Nashville Housing Data For data cleaning v1] a
Join [Nashville Housing Data For data cleaning v1] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null	


-- Breaking out Address into Individual Columns (Address,City,State)

Select PropertyAddress
From [Nashville Housing Data For data cleaning v1]
--where PropertyAddress is null 

Select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS Address,
CHARINDEX(',',PropertyAddress)
From [Nashville Housing Data For data cleaning v1]

Select 
PropertyAddress,
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address,
Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City,
From [Nashville Housing Data For data cleaning v1]

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data For data cleaning v1]
Set PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)
From [Nashville Housing Data For data cleaning v1]

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing Data For data cleaning v1]
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
From [Nashville Housing Data For data cleaning v1]

-- Owenr Address

Select OwnerAddress
FROM [Nashville Housing Data For data cleaning v1]

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) As Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1) AS State
From [Nashville Housing Data For data cleaning v1]

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add OwnerAddressSpitAddress Nvarchar(255);

UPDATE [Nashville Housing Data For data cleaning v1]
SET OwnerAddressSpitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add OwnerAddressSplitCity Nvarchar(255);

UPDATE [Nashville Housing Data For data cleaning v1]
SET OwnerAddressSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [Nashville Housing Data For data cleaning v1]
Add OwnerAddressSplitState Nvarchar(255);

UPDATE [Nashville Housing Data For data cleaning v1]
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From [Nashville Housing Data For data cleaning v1]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From [Nashville Housing Data For data cleaning v1]

UPDATE [Nashville Housing Data For data cleaning v1]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
         ParcelID,
		 PropertyAddress,
		 SalePrice,
		 SaleDate,
		 LegalReference
		 ORDER BY UniqueID
		 )row_num
From [Nashville Housing Data For data cleaning v1]
ORDER BY ParcelID

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
         ParcelID,
		 PropertyAddress,
		 SalePrice,
		 SaleDate,
		 LegalReference
		 ORDER BY UniqueID
		 )row_num
From [Nashville Housing Data For data cleaning v1]
)

DELETE 
From RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

Select *
FROM [Nashville Housing Data For data cleaning v1]

ALTER TABLE [Nashville Housing Data For data cleaning v1]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing Data For data cleaning v1]
DROP COLUMN SaleDate

