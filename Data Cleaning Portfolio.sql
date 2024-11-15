/* Cleaning Data in SQL Queries */

Select * from NavshvilleHousing

------------------------------------------------------------------


--Standardize date format--

Select SaleDateConverted, CONVERT(Date, SaleDate) 
from NavshvilleHousing


Update NavshvilleHousing 
SET SaleDate=CONVERT(Date, SaleDate) ---It doesn't worked out so we use alter the table and add new column then we updated


ALTER TABLE NavshvilleHousing
Add SaleDateConverted Date;

Update NavshvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------

--Populate Property Address Data

Select PropertyAddress from NavshvilleHousing where PropertyAddress is null

Select *
from NavshvilleHousing
--where PropertyAddress is null 
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NavshvilleHousing a
join NavshvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]


Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NavshvilleHousing a
join NavshvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is Null


----------------------------------------------------------------------------------------------------------

----Breaking out Address into Individual columns (Address, City, State)

Select PropertyAddress from NavshvilleHousing



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 
FROM NavshvilleHousing


----EASY WAY TO BREAKOUT THE PROPERTY ADDRESS INDIVIDUALLY
SELECT 
PARSENAME(REPLACE(PropertyAddress, ',','.'),2),
PARSENAME(REPLACE(PropertyAddress, ',','.'),1)
FROM NavshvilleHousing

ALTER TABLE NavshvilleHousing
add PropertySplitAddress Nvarchar(255)

Update NavshvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NavshvilleHousing
add PropertySplitCity Nvarchar(255)

Update NavshvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 

SELECT * FROM NavshvilleHousing


SELECT OwnerAddress
FROM NavshvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NavshvilleHousing

ALTER TABLE NavshvilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update NavshvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NavshvilleHousing
ADD OwnerSplitCity nvarchar(255)

Update NavshvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NavshvilleHousing
ADD OwnerSplitState nvarchar(255)

Update NavshvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NavshvilleHousing


-------------------------------------------------------------------

--Change 'Y' and 'N' to 'Yes' and 'No' for SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NavshvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NavshvilleHousing

UPDATE NavshvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NavshvilleHousing


-----------------------------------------------------------------------------row number is used to segregate how many duplicate records are in

---- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID
			 )
			 row_num
FROM NavshvilleHousing
)

SELECT * FROM RowNumCTE
WHERE row_num >1
ORDER BY UniqueID

--DELETE  FROM RowNumCTE
--WHERE row_num >1

SELECT * FROM NavshvilleHousing


----------------------------------------------------------------------------------

---Delete Unused Columns

SELECT * FROM NavshvilleHousing

ALTER TABLE NavshvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress, SaleDate
