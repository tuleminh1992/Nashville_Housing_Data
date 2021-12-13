/* 
Cleaning Data in SQL Queries
*/

Select * from dbo.Sheet1$
----------------------------------------------------------------------------------------------

-- Change the SaleDate column from DateTime to Date - STANDARDIZE DATE FORMAT

Select cast(SaleDate as Date) as Date --- CONVERT(Date, SaleDate)
From dbo.Sheet1$

Update dbo.Sheet1$
Set SaleDate = CONVERT(Date, SaleDate) --- This does not work on the table

ALTER TABLE dbo.Sheet1$ --- USE ALTER TABLE to create a new Column named SaleDateConverted
Add SaleDateConverted Date;

Update dbo.Sheet1$
Set SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from dbo.Sheet1$
where PropertyAddress is null --- Investigate NULL value

Select * 
from dbo.Sheet1$
order by ParcelID --- Same ParcelID has same Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress) 
																	--- ISNULL() return b.PropertyAddress if a.PropertyAddress is NULL
From dbo.Sheet1$ a
Join dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From dbo.Sheet1$ a
Join dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

----------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.Sheet1$

Select PropertyAddress, 
		SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress,0)) as Address,                          --- BEFORE 
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City		--- AFTER
From dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
Add Property_Split_Address Nvarchar(255);
Update dbo.Sheet1$
Set Property_Split_Address = SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress,0));

ALTER TABLE dbo.Sheet1$
Add Property_Split_City Nvarchar(255);
Update dbo.Sheet1$
Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--- Another Solution

Select 
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1) as State
From dbo.Sheet1$

ALTER TABLE dbo.Sheet1$
Add Owner_Split_Address Nvarchar(255);
Update dbo.Sheet1$
Set Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3);

ALTER TABLE dbo.Sheet1$
Add Owner_Split_City Nvarchar(255);
Update dbo.Sheet1$
Set Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2);

ALTER TABLE dbo.Sheet1$
Add Owner_Split_State Nvarchar(255);
Update dbo.Sheet1$
Set Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1);

--------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From dbo.Sheet1$
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
	Case
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From dbo.Sheet1$

Update dbo.Sheet1$
Set SoldAsVacant = 
	Case
		When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End



--------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(         -- Specifies a temporary named result set, known as a common table expression (CTE)
Select *,
	ROW_NUMBER() OVER (				 --- Row_Number() assigns a sequential integer to each row within the partition of a result set
	PARTITION BY ParcelID,           --- Partition By divides the result set into partitions (groups of rows) 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num        --- Order_By() defines the logical order of rows within each partition of the result set
from dbo.Sheet1$ )
Select *
From RowNumCTE

--- Duplicate value
WITH RowNumCTE AS(         -- Specifies a temporary named result set, known as a common table expression (CTE)
Select *,
	ROW_NUMBER() OVER (				 --- Row_Number() assigns a sequential integer to each row within the partition of a result set
	PARTITION BY ParcelID,           --- Partition By divides the result set into partitions (groups of rows) 
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num        --- Order_By() defines the logical order of rows within each partition of the result set
from dbo.Sheet1$ )
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


WITH RowNumCTE AS(         -- Specifies a temporary named result set, known as a common table expression (CTE)
Select *,
	ROW_NUMBER() OVER (				 --- Row_Number() assigns a sequential integer to each row within the partition of a result set
	PARTITION BY ParcelID,           --- Partition By divides the result set into partitions (groups of rows) 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num        --- Order_By() defines the logical order of rows within each partition of the result set
from dbo.Sheet1$ )
Delete 
From RowNumCTE
Where row_num > 1




--------------------------------------------------------------------------------------------
-- REMOVE UNUSED COLUMNS

Alter Table dbo.Sheet1$
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Select *
from dbo.Sheet1$

