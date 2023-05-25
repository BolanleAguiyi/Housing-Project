select * from [nashville housing].dbo. projectportfolio

--Change DateFormat from DateTime to Date

 alter table ProjectPortfolio
 add ConvertedSaleDate date

 select convert(date,Saledate) from ProjectPortfolio

 update ProjectPortfolio 
 set ConvertedSaleDate=convert(date,Saledate)

 --Populating Property Address data because i realized some records had NULL values 

  select * from [nashville housing].dbo. projectportfolio
  select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)NewPropertyAddress from ProjectPortfolio A
  inner join ProjectPortfolio B
  on A.ParcelID=B.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
  where b.PropertyAddress is null

  update a
  set PropertyAddress=  ISNULL(a.propertyAddress, b.PropertyAddress) from ProjectPortfolio A
  inner join ProjectPortfolio B
  on A.ParcelID=B.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
  where a.PropertyAddress is null

  --Breaking out address into individual columns(Address, city, state) to enable Slicing and Dicing at the lowest form

  select PropertyAddress from  projectportfolio

  select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyAddress)) as Address
  from ProjectPortfolio
  

 alter table ProjectPortfolio
 add SplitedAddress nvarchar(255)

  alter table ProjectPortfolio
 add SplitedCity nvarchar(255)

  update ProjectPortfolio
  set SplitedAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)
  from ProjectPortfolio

   update ProjectPortfolio
  set SplitedCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(propertyAddress))
  from ProjectPortfolio



  alter table projectPortfolio
  add OwnerSplitAddress nvarchar(255)

   alter table projectPortfolio
  add OwnerSplitCity nvarchar(255)

   alter table projectPortfolio
  add OwnerSplitState nvarchar(255)


  select PARSENAME(Replace(OwnerAddress,',','.'), 3) ,
 PARSENAME(Replace(OwnerAddress,',','.'), 2) ,
 PARSENAME(Replace(OwnerAddress,',','.'), 1) from ProjectPortfolio


  update ProjectPortfolio
  set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'), 3) 
  from ProjectPortfolio

  update ProjectPortfolio
  set OwnerSplitCity= PARSENAME(Replace(OwnerAddress,',','.'), 2) 
  from ProjectPortfolio

    update ProjectPortfolio
  set OwnerSplitState= PARSENAME(Replace(OwnerAddress,',','.'), 1) 
  from ProjectPortfolio

  -- change Y and N to Yes and No in "Sold as vacant" field

  select soldasvacant,
  case SoldAsVacant
  when 'N' then 'No'
  when 'Y' then 'Yes'
  else SoldAsVacant
  end
  
  from ProjectPortfolio

update ProjectPortfolio
set soldasvacant=
  case SoldAsVacant
  when 'N' then 'No'
  when 'Y' then 'Yes'
  else SoldAsVacant
  end
  from ProjectPortfolio

  -- Checking for duplicate records, this shows there is 104 duplicate records 

  with Duplicate_Data as (
  select *, row_number() over ( 
  partition by parcelID,saleDate,SalePrice, PropertyAddress,LegalReference
  order by uniqueID
  ) as Duplicate_Data from ProjectPortfolio
  )
  select * from Duplicate_data
  where Duplicate_Data>1

  --Create view for the clean data

  Create view CleanedNashvilleHousing as 
  select UniqueID, ParcelID, LandUse,SalePrice,LegalReference,SoldAsVacant,Acreage,TaxDistrict,LandValue,BuildingValue,TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath,
  convertedSaleDate,SplitedAddress, SplitedCity,OwnerSplitAddress,OwnerSplitCity,OwnersplitState from ProjectPortfolio


  with Duplicate_Data as (
  select *, row_number() over ( 
  partition by parcelID,ConvertedSaleDate,SalePrice, SplitedAddress,LegalReference
  order by uniqueID
  ) as Duplicate_Data from CleanedNashvilleHousing
  )
  select * from Duplicate_data

  where Duplicate_Data>1

 select * from CleanedNashvilleHousing
