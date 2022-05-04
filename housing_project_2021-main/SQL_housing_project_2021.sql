-----------------------------------------
--NASHVILLE HOUSING DATA CLEANING PROJECT
-----------------------------------------

-----------------
--Checking import

SELECT
	*
FROM
	Housing_Project.dbo.HousingProject

--------------------
--Remove TaxDistrict

ALTER TABLE
	Housing_Project.dbo.HousingProject
DROP COLUMN
	TaxDistrict

--[x]Standardize SaleDate
--[x]Fix PropertyAddress Nulls
--[x]Split PropertyAddress
--[x]Create consistency in SoldAsVacant
--[x]Remove duplicates

----------------------
--Standardize SaleDate

SELECT
	SaleDate
FROM
	Housing_Project.dbo.HousingProject

SELECT
	CONVERT(Date, SaleDate)
FROM
	Housing_Project.dbo.HousingProject

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	SaleDateNew Date

UPDATE
	Housing_Project.dbo.HousingProject
SET
	SaleDateNew = CONVERT(Date, SaleDate)

ALTER TABLE
	Housing_Project.dbo.HousingProject
DROP COLUMN
	SaleDate

---------------------------
--Fix PropertyAddress Nulls

SELECT
	*
FROM
	Housing_Project.dbo.HousingProject
WHERE
	PropertyAddress is NULL

SELECT
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	Housing_Project.dbo.HousingProject a
JOIN
	Housing_Project.dbo.HousingProject b
	ON
		a.ParcelID = b.ParcelID
	AND 
		a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress is NULL

UPDATE
	a
SET
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	Housing_Project.dbo.HousingProject a
JOIN
	Housing_Project.dbo.HousingProject b
	ON
		a.ParcelID = b.ParcelID
	AND 
		a.UniqueID <> b.UniqueID

------------------------------------
--Split PropertyAddress (substrings)

SELECT
	PropertyAddress
FROM
	Housing_Project.dbo.HousingProject

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM
	Housing_Project.dbo.HousingProject

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	PropertyCity NVARCHAR(255)

UPDATE
	Housing_Project.dbo.HousingProject
SET
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	PropertyAddresses NVARCHAR(255)

UPDATE
	Housing_Project.dbo.HousingProject
SET
	PropertyAddresses = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE
	Housing_Project.dbo.HousingProject
DROP COLUMN
	PropertyAddress

SELECT
	*
FROM
	Housing_Project.dbo.HousingProject

-----------------------------------
--Split PropertyAddress (parsename)

SELECT
	OwnerAddress
FROM
	Housing_Project.dbo.HousingProject

SELECT
	PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 1)
FROM
	Housing_Project.dbo.HousingProject

--

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	OwnerAddressSplit NVARCHAR(255)

UPDATE
	Housing_Project.dbo.HousingProject
SET
	OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 3)

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	OwnerCitySplit NVARCHAR(255)

UPDATE
	Housing_Project.dbo.HousingProject
SET
	OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 2)

ALTER TABLE
	Housing_Project.dbo.HousingProject
ADD
	OwnerStateSplit NVARCHAR(255)

UPDATE
	Housing_Project.dbo.HousingProject
SET
	OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 1)

ALTER TABLE
	Housing_Project.dbo.HousingProject
DROP COLUMN
	OwnerAddress

------------------------------------
--SoldAsVacant Y and N to Yes and No

SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM
	Housing_Project.dbo.HousingProject
GROUP BY
	SoldAsVacant

SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM
	Housing_Project.dbo.HousingProject

UPDATE
	Housing_Project.dbo.HousingProject
SET
	SoldAsVacant = 	CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END

-------------------
--Remove Duplicates

WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER (
		PARTITION BY	
			ParcelID,
			PropertyAddresses,
			SalePrice,
			SaleDateNew,
			LegalReference
			ORDER BY
				UniqueID
						) row_num
FROM
	Housing_Project.dbo.HousingProject
)

DELETE
FROM
	RowNumCTE
WHERE
	row_num > 1

	
SELECT
	*
FROM
	Housing_Project.dbo.HousingProject
