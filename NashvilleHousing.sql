select top 18 *
from PortfolioProject..NashvilleHousing

--clean the date column to short date format

select * from PortfolioProject..NashvilleHousing

alter Table NashvilleHousing
add SaleDateConverted date;

update	NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

--populate property address data

select a.PropertyAddress, b.PropertyAddress
from NashvilleHousing a
Join Nashvillehousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where b.PropertyAddress is null

update a
set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join Nashvillehousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- breaking out address into individual column (address, city state_)

select PropertyAddress from PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(225)

update	NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter Table NashvilleHousing
add PropertySplitCity Nvarchar(225)

update	NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select *from PortfolioProject..NashvilleHousing

--parse owner address
select 
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(225)

update	NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(225)

update	NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter Table NashvilleHousing
add OwnerSplitState Nvarchar(225)

update	NashvilleHousing
set OwnerSplitState  = PARSENAME(replace(OwnerAddress,',','.'),1)

select *from PortfolioProject..NashvilleHousing

--change Y and N to Yes and No in "Sold as Vacant field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant) c
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End

--remove duplicates

select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID
			) row_num
from PortfolioProject..NashvilleHousing

With RowNumCTE As (
select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID
			) row_num
from PortfolioProject..NashvilleHousing)

Delete from RowNumCTE
where row_num >1

--check whehther the duplicates are deleted

With RowNumCTE As (
select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID
			) row_num
from PortfolioProject..NashvilleHousing)

Select * from RowNumCTE
where row_num >1


--delete unused columns

Alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject..NashvilleHousing
drop column SaleDate

Select * from PortfolioProject..NashvilleHousing

