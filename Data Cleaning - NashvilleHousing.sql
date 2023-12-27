-- Data Cleaning

SELECT *
FROM public."NashvilleHousing"



-- Populate Property Address Data


SELECT "PropertyAddress"
FROM public."NashvilleHousing"


SELECT *
FROM public."NashvilleHousing"
WHERE "PropertyAddress" is null
ORDER BY "ParcelID"



SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM public."NashvilleHousing" a
JOIN public."NashvilleHousing" b
	ON a."ParcelID" = b."ParcelID"
	AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" is null



Update public."NashvilleHousing" a
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM public."NashvilleHousing" b
WHERE a."ParcelID" = b."ParcelID" 
AND a."UniqueID " <> b."UniqueID " 
AND a."PropertyAddress" IS NULL;



-- Breaking out Address into Individual Columns (Address, City, State)


SELECT "PropertyAddress"
FROM public."NashvilleHousing"


SELECT
SUBSTRING("PropertyAddress" FROM 1 For Position(',' In "PropertyAddress") - 1) As "Address",
SUBSTRING("PropertyAddress" FROM Position(',' In "PropertyAddress") + 1) As "City"
FROM public."NashvilleHousing"



ALTER TABLE "NashvilleHousing"
ADD "PropertySplitAddress" text;

UPDATE "NashvilleHousing"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress" FROM 1 FOR POSITION(',' IN "PropertyAddress") - 1)



ALTER TABLE "NashvilleHousing"
ADD "PropertySplitCity" text;

UPDATE "NashvilleHousing"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress" FROM POSITION(',' IN "PropertyAddress") + 1)



SELECT *
FROM public."NashvilleHousing"


SELECT "OwnerAddress"
FROM public."NashvilleHousing"


SELECT
SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 1),
SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 2),
SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 3)
FROM public."NashvilleHousing"


ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitAddress" text;

UPDATE "NashvilleHousing"
SET "OwnerSplitAddress" = SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 1)



ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitCity" text;

UPDATE "NashvilleHousing"
SET "OwnerSplitCity" = SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 2)


ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitState" text;

UPDATE "NashvilleHousing"
SET "OwnerSplitState" = SPLIT_PART(REPLACE("OwnerAddress", ',', '.') , '.', 3)


SELECT *
FROM public."NashvilleHousing"


-- Change Y and N to Yes and No in "SoldAsVacant" column

SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM public."NashvilleHousing"
GROUP BY "SoldAsVacant"
ORDER BY 2


SELECT "SoldAsVacant",
	CASE
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END
FROM public."NashvilleHousing"


UPDATE "NashvilleHousing"
SET "SoldAsVacant" = CASE
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END

SELECT *
FROM public."NashvilleHousing"



-- Remove Duplicates

WITH Row_Num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SaleDate",
				 "SalePrice",
				 "LegalReference"
	ORDER BY "UniqueID ") "RowNum"
FROM public."NashvilleHousing"
--ORDER BY "ParcelID"
)	

DELETE 
FROM public."NashvilleHousing"
WHERE ("ParcelID", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference") 
IN (
    SELECT "ParcelID", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference"
    FROM Row_Num_CTE
    WHERE "RowNum" > 1
)




-- Delete Unused Columns



SELECT *
FROM public."NashvilleHousing"


ALTER TABLE public."NashvilleHousing"
DROP COLUMN "OwnerAddress", 
DROP COLUMN "TaxDistrict", 
DROP COLUMN "PropertyAddress", 
DROP COLUMN "SaleDate"
