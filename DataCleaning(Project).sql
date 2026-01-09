-- Data Cleaning

select *
from layoffs;

Create table layoffs_staging
like layoffs;

Select * 
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

-- 1. Remove Duplicates
Select * 
from layoffs_staging;

select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, stage, country, `date`) As row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, stage, country, `date`) As row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * 
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, stage, country, `date`) As row_num
from layoffs_staging;

Select * 
from layoffs_staging2
where row_num > 1;

Delete
from layoffs_staging2
where row_num > 1;

Select * 
from layoffs_staging2;

-- 2. Standardized the Data

Select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
set company = TRIM(company);

Select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry LIKE 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
Where industry like 'crypto%';

Select distinct location, country
from layoffs_staging2
order by 1;

update layoffs_staging2
set location = 'Florianópolis'
where location like 'FlorianÃ³polis';

update layoffs_staging2
set location = 'Düsseldorf'
where location like 'DÃ¼sseldorf';

update layoffs_staging2
set location = 'Malmo'
where location like 'MalmÃ¶';

update layoffs_staging2
set country = 'Norway'
where location like 'Oslo';

update layoffs_staging2
set country = 'Israel'
where location like 'Tel Aviv';

update layoffs_staging2
set country = 'United States'
where country like 'United States%';

update layoffs_staging2
set country = 'United States'
where location like 'SF Bay Area';

update layoffs_staging2
set country = 'China'
where location like 'Beijing';

update layoffs_staging2
set country = 'Germany'
where location like 'Berlin';

update layoffs_staging2
set country = 'Australia'
where location like 'Brisbane';

update layoffs_staging2
set country = 'India'
where location like 'Chennai';

update layoffs_staging2
set country = 'Denmark'
where location like 'Copenhagen';

update layoffs_staging2
set country = 'United Arab Emirates'
where location like 'Dubai';

update layoffs_staging2
set country = 'United Kingdom'
where location like 'London';

update layoffs_staging2
set country = 'Mexico'
where location like 'Mexico City';

update layoffs_staging2
set country = 'Australia'
where location like 'Melbourne';

update layoffs_staging2
set country = 'India'
where location like 'New Delhi';

update layoffs_staging2
set country = 'Brazil'
where location like 'Sao Paulo';

update layoffs_staging2
set country = 'Singapore'
where location like 'Singapore';

update layoffs_staging2
set country = 'Sweden'
where location like 'Stockholm';

update layoffs_staging2
set country = 'Australia'
where location like 'Sydney';

update layoffs_staging2
set country = 'Japan'
where location like 'Tokyo';

update layoffs_staging2
set country = 'Canada'
where location like 'Toronto';

update layoffs_staging2
set country = 'Canada'
where location like 'Vancouver';

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

Alter table layoffs_staging2
modify column `date` date;

-- 3. Null Values or blank values

select *
from layoffs_staging2
where industry is null or industry = '';

select *
from layoffs_staging2
where company like 'Airbnb';

update layoffs_staging2
set industry = 'Travel'
where company = 'Airbnb';

select *
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2
where company like 'Bally%';

-- 4. Remove any unneccessary columns or rows

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;

