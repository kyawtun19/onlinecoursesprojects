CREATE TABLE netflix (
    show_id TEXT,
    type TEXT,
    title TEXT,
    director TEXT,
    country TEXT,
    date_added TEXT,
    release_year INTEGER,
    rating TEXT,
    duration TEXT,
    listed_in TEXT
)

COPY Netflix
FROM 'C:\Users\Public\netflix.csv'
WITH (FORMAT CSV,HEADER);

-- Creating entirely new table backup
CREATE TABLE Netflix_backup AS TABLE Netflix;

-- Creating duplicate columns in the BACKUP Table 

ALTER TABLE Netflix_backup ADD COLUMN show_id_duplicate TEXT;
UPDATE Netflix_backup SET show_id_duplicate = show_id;

ALTER TABLE Netflix_backup ADD COLUMN type_duplicate TEXT;
UPDATE Netflix_backup SET type_duplicate = type;

ALTER TABLE Netflix_backup ADD COLUMN title_duplicate TEXT;
UPDATE Netflix_backup SET title_duplicate = title;

ALTER TABLE Netflix_backup ADD COLUMN director_duplicate TEXT;
UPDATE Netflix_backup SET director_duplicate = director;

ALTER TABLE Netflix_backup ADD COLUMN country_duplicate TEXT;
UPDATE Netflix_backup SET country_duplicate = country;

ALTER TABLE Netflix_backup ADD COLUMN date_added_duplicate TEXT;
UPDATE Netflix_backup SET date_added_duplicate = date_added;

ALTER TABLE Netflix_backup ADD COLUMN release_year_duplicate INTEGER;
UPDATE Netflix_backup SET release_year_duplicate = release_year;

ALTER TABLE Netflix_backup ADD COLUMN rating_duplicate TEXT;
UPDATE Netflix_backup SET rating_duplicate = rating;

ALTER TABLE Netflix_backup ADD COLUMN duration_duplicate TEXT;
UPDATE Netflix_backup SET duration_duplicate = duration;

ALTER TABLE Netflix_backup ADD COLUMN listed_in_duplicate TEXT;
UPDATE Netflix_backup SET listed_in_duplicate = listed_in;


/* 
	Upon studying the csv file in details, there're missing values in the director column. The datatype is string/text so in one look,
	one might not see the missing value because it is written 'not given'. But understanding the context, it is missing value.
*/

select director_duplicate from Netflix_backup
where director_duplicate = 'Not Given';

/* 
	Removing those 'Not Given' to null value.
*/

UPDATE Netflix_backup
SET director_duplicate = NULL
WHERE director_duplicate = 'Not Given';

-- In this step, checking if 'Not Given' is replaced to NULL. 
SELECT director_duplicate FROM Netflix_backup;

--Perform step 3 using a second method (e.g. a, b or c from above) on a different column

/*
	There was ‘Not Given’ in the country_duplicate column of Netflix_backup.
First, identify those ‘Not Given’ in the country_duplicate column from the Netflix_backup. 
Second, replace ‘Not Given’ with NULL. 
Third, removing the data containing null values. 
*/

--Identify 'Not Given' Values
SELECT * FROM Netflix_backup WHERE country_duplicate = 'Not Given';

--Replace 'Not Given' with NULL
UPDATE Netflix_backup
SET country_duplicate = NULL
WHERE country_duplicate = 'Not Given';

--Check if 'Not Given' were replaced with NULL 
SELECT country_duplicate FROM Netflix_backup;

--Remove Rows Containing NULL Values
DELETE FROM Netflix_backup WHERE country_duplicate IS NULL;

-- Check if NULL were removed
SELECT country_duplicate FROM Netflix_backup;

/* 
Group similar values (i.e. - Sr., Senior, Sr from the video), misspelled, or inconsistent
data for one column such that the data is correct and consistent. Only one group of
similar values need to be cleaned, not the entire column */

--There were two inconsistent values - minutes and seasons in the duration_duplicate. 

--Identify the 'Season' Values
SELECT duration_duplicate FROM netflix_backup
WHERE duration_duplicate LIKE '%Season%';

--Extract the Number of Seasons
SELECT SPLIT_PART(duration_duplicate, ' ', 1)::INTEGER AS number_of_seasons
FROM netflix_backup
WHERE duration_duplicate LIKE '%Season%';

/* 1 season is equal to roughly 540 minutes. 1 episode is 45 minutes.
1 season contains 10-12 episodes. 12 episodes * 45 minutes = 540 minutes */

--Convert Seasons to Minutes
UPDATE netflix_backup
SET duration_duplicate = (SPLIT_PART(duration_duplicate, ' ', 1)::INTEGER * 540)::TEXT || ' min'
WHERE duration_duplicate LIKE '%Season%';

--Verify the Changes
SELECT duration_duplicate FROM netflix_backup;

--Repeat step 5 on another column.

/* Non-Latin characters were found in the title_duplicate column and need to be grouped first, then removed. */ 

-- Identify rows with non-Latin characters in the title_duplicate column
SELECT title_duplicate
FROM netflix_backup
WHERE title_duplicate ~ '[^\x00-\x7F]';

-- Delete rows with non-Latin characters in the title_duplicate column
DELETE FROM netflix_backup
WHERE title_duplicate ~ '[^\x00-\x7F]';

-- Test if non-Latin characters have been removed from the title_duplicate column
SELECT title_duplicate
FROM netflix_backup
WHERE title_duplicate ~ '[^\x00-\x7F]';

--Step 7

/* The other data cleaning method that should be done is removing duplicates. 
For example, what if show_id gets duplicates? 
In a database where the show_id represents a unique identifier for each movie or TV show, 
having duplicate values in the show_id column would likely mean that the same movie or 
TV show is listed more than once. This could lead to redundancy and confusion in the data, 
so removing duplicates based on the show_id is a sensible data-cleaning step.
*/
-- Identify duplicate show_id_duplicate values
SELECT show_id_duplicate, COUNT(*)
FROM netflix_backup
GROUP BY show_id_duplicate
HAVING COUNT(*) > 1;

---- Remove duplicate rows based on the show_id_duplicate
DELETE FROM netflix_backup
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM netflix_backup
  GROUP BY show_id_duplicate
);

-- Verify that duplicates have been removed based on the show_id_duplicate
SELECT show_id_duplicate, COUNT(*)
FROM netflix_backup
GROUP BY show_id_duplicate
HAVING COUNT(*) > 1;



