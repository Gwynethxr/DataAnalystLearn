/*
Data Cleaning in SQL Queries

*/

Select * From PortfolioProject..NasvilleHosting
--Standarize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NasvilleHosting

Update NasvilleHosting
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NasvilleHosting
add SaleDateConverted Date;

UPDATE NasvilleHosting
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data
Select * 
From PortfolioProject..NasvilleHosting 
--Where PropertyAddress is null
ORDER BY ParcelID

--Check where propertyAdress is null if Null b.PropertyAddress will populate a.PropertyAddress using ISNULL()
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NasvilleHosting a
JOIN PortfolioProject..NasvilleHosting b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NasvilleHosting a
JOIN PortfolioProject..NasvilleHosting b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking Address with Substring  and CHARINDEX(',') and add With Alter Table then UPDATE
Select PropertyAddress
From PortfolioProject..NasvilleHosting 

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress)) as Address
From PortfolioProject..NasvilleHosting 

ALTER TABLE NasvilleHosting
add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NasvilleHosting
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 

ALTER TABLE NasvilleHosting
add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NasvilleHosting
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress))

Select * From PortfolioProject..NasvilleHosting

-- Owner Address 
Select OwnerAddress
From PortfolioProject..NasvilleHosting

Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1) 
	From PortfolioProject..NasvilleHosting

ALTER TABLE NasvilleHosting
add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NasvilleHosting
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3)

ALTER TABLE NasvilleHosting
add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NasvilleHosting
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2)

ALTER TABLE NasvilleHosting
add OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NasvilleHosting
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1)

------------------------------------------------
-- Change Y and N to Yes and No in "Sold As Vacant" field

 Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
 From PortfolioProject..NasvilleHosting
 Group BY SoldAsVacant
 Order by 2

 Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
		END
 From PortfolioProject..NasvilleHosting

 UPDATE PortfolioProject..NasvilleHosting
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						 WHEN SoldAsVacant = 'N' THEN 'NO'
					ELSE SoldAsVacant
						END

----------------------------------------------------------------------------------------------
-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) row_num
From PortfolioProject..NasvilleHosting
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


Select * 
From PortfolioProject..NasvilleHosting

----------------------------------------------------------------------------------------------
-- Delete Unused  Columns

Select *
From PortfolioProject..NasvilleHosting

ALTER TABLE PortfolioProject..NasvilleHosting
DROP Column OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NasvilleHosting
DROP Column SaleDate