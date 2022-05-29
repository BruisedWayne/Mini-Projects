-- Cleaning Data - Nashville Housing Dataset

Select * 
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------
-- Standardize Date Format

Select SaleDate, SaleDateConverted
--, Convert(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing	

Update NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = convert (Date,SaleDate)

----------------------------------------------------------

-- Populate Property Address Data

Select * 
From PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
on A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null

Update A
SET PropertyAddress = isnull (A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
on A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
Where A.PropertyAddress is null



----------------------------------------------------
-- Breaking Address into Address, City, State etc.

Select PropertySplitAddress, PropertySplitCity
From PortfolioProject.dbo.NashvilleHousing


Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing
 
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Same thing using Parse instead of Substrings

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


---------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldasVacant), count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldasVacant
Order by count(Soldasvacant)


Select SoldasVacant
, CASE when SoldasVacant = 'Y' THEN 'Yes'
	   when SoldasVacant = 'N' THEN 'No'
	   Else SoldasVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldasVacant = CASE when SoldasVacant = 'Y' THEN 'Yes'
						when SoldasVacant = 'N' THEN 'No'
						Else SoldasVacant
						END


-------------------------------------------------------------------------------
--Remove Duplicates

/*Making the CTE that stores duplicate rows*/

WITH RowNumCTE AS (
Select *,
	ROW_Number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

/*Querying off CTE to display all duplicate rows*/
Select * 
From RowNumCTE
Where row_num>1
Order by PropertyAddress


/*Querying off the CTE to DELETE duplicate rows*/

WITH RowNumCTE AS (
Select *,
	ROW_Number() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE 
From RowNumCTE
Where row_num>1
--Order by PropertyAddress



-----------------------------------------------------------------------------

--Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



------------------------------------------------------------------------------
