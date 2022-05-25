-- Data Cleaning --
-- 1. Standaradize date format
-- 2. Populate Property Address data
		-- Using join to itself
-- 3. Breaking out address  into individual columns (Address, City, States)
		-- Substring, Charindex
		-- Alternative method using Parsename & Replace (Simpler and more effective)
-- 4. Change Y and N to Yes and No in "Sold as Vacant" field
-- 5. Remove duplicates
		-- Using CTE and Rownum() & OVER Partition by
-- 6. Delete some unused columns
		-- Using Drop

-----------------------------------------------------------------------------------------------------------

-- START

select *
from PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------

-- Standaradize date format

select SaleDateConverted, CONVERT(date,saledate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate)

alter table NashvilleHousing -- this one 1st
add Saledateconverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,saledate) -- this 2nd


-----------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
	on a.parcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Learning points: 
--		1. Joining tables to itself to populate a missing data that has a repeat.
--		2. In this case, parcelID and column that needs to be populated, PropertyAdress are linked. 
--		3. Using isnull to create a secondary row and use that row to update the db.



-----------------------------------------------------------------------------------------------------------

-- Breaking out address  into individual columns (Address, City, States)


select *
from PortfolioProject.dbo.NashvilleHousing


select
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address -- Charindex gives a number, to remove the come, need to -1
, substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing 

--------- Creating Split Adress Column ----------------------------

ALTER table NashvilleHousing				-- Creating Column
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing						-- Populating the column
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

--------- Creating Split city Column ----------------------------

ALTER table NashvilleHousing				-- Creating Column
add PropertySplitCity Nvarchar(255);

update NashvilleHousing						-- Populating the column
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--------- Alternative method ----------------------------

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(Replace (OwnerAddress, ',', '.') ,3) as Address1, 
PARSENAME(Replace (OwnerAddress, ',', '.') ,2) as City1,
PARSENAME(Replace (OwnerAddress, ',', '.') ,1) as State1
from PortfolioProject.dbo.NashvilleHousing


ALTER table NashvilleHousing				-- Creating Column
add OwnerSplitAddress Nvarchar(255);

ALTER table NashvilleHousing				-- Creating Column
add OwnerSplitCity Nvarchar(255);

ALTER table NashvilleHousing				-- Creating Column
add OwnerSplitState Nvarchar(255);


update NashvilleHousing						-- Populating the column
set OwnerSplitAddress = PARSENAME(Replace (OwnerAddress, ',', '.') ,3)

update NashvilleHousing						-- Populating the column
set OwnerSplitCity = PARSENAME(Replace (OwnerAddress, ',', '.') ,2)

update NashvilleHousing						-- Populating the column
set OwnerSplitState = PARSENAME(Replace (OwnerAddress, ',', '.') ,1) 

select *
from PortfolioProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),COUNT(SOldasVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end as NewSoldAsVacant
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing						-- Updating the column
set SoldAsVacant = 
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end


-----------------------------------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE as (
select *,
ROW_NUMBER() OVER (
PARTITION BY	ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) as row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

Delete -- Check the table first with select * before deleting
from RowNumCTE
Where row_num > 1


-----------------------------------------------------------------------------------------------------------

-- Delete some unused columns

-- We dont do this to the raw data
-- Use it more for temp data or views

select *
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
