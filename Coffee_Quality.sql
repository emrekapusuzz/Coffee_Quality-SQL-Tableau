-- PART I  DATA CLEANING
-- SKILLS USED: UPDATE, ALTER, SUBSTRING_INDEX, CONCAT, WHERE, LIKE, REGEXP_REPLACE, CASE  & WHEN
 
-- SELECT THE DATA We will be working on

SELECT * FROM merged_data_cleaned;

	-- 1. Change Feature Names Where has '.'

ALTER TABLE `coffee`.`merged_data_cleaned` 
ENGINE = InnoDB ,
CHANGE COLUMN `Country.of.Origin` `Country_of_Origin` TEXT NULL DEFAULT NULL,
CHANGE COLUMN `Farm.Name` `Farm_Name` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Lot.Number` `Lot_Number` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `ICO.Number` `ICO_Number` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Number.of.Bags` `Number_of_Bags` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Bag.Weight` `Bag_Weight` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `In.Country.Partner` `In_Country_Partner` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Harvest.Year` `Harvest_Year` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Grading.Date` `Grading_Date` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Owner.1` `Owner_1` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Processing.Method` `Processing_Method` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Clean.Cup` `Clean_Cup` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Cupper.Points` `Cupper_Points` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Total.Cup.Points` `Total_Cup_Points` DOUBLE NULL DEFAULT NULL,
CHANGE COLUMN `Category.One.Defects` `Category_One_Defects`  INT NULL DEFAULT NULL ,
CHANGE COLUMN `Category.Two.Defects` `Category_Two_Defects` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Certification.Body` `Certification_Body` TEXT NULL DEFAULT NULL;

		-- Change to DATE TIME
-- ALTER TABLE `coffee_qual`.`coffee`
	-- CHANGE COLUMN `Grading_Date` `Grading_Date` DATETIME NULL DEFAULT NULL ,
	-- CHANGE COLUMN `Expiration` `Expiration` DATETIME NULL DEFAULT NULL ;

		-- 2. Change country names that has United States (something) and return names in brackets

UPDATE merged_data_cleaned
SET 
    Country_of_Origin = substring_index(substring_index(Country_of_Origin, '(',-1), ')', 1)
    WHERE Country_of_Origin LIKE 'United States (%';

		-- 3. Changing unknown values to Null in ICO_Number

UPDATE merged_data_cleaned
SET
	ICO_Number = Null 
    WHERE ICO_Number LIKE '%un%';
    
UPDATE merged_data_cleaned
SET
	ICO_Number = Null 
    WHERE ICO_Number = 0;

		-- 4. Investigate and update Bag_weight
        
SELECT Bag_Weight FROM merged_data_cleaned;
	    -- 4a. Some bag_weights are about 10k kgs. I think these are kg * number_of_bags
        -- 4a. Rows have 'KG' and 'LBS'; convert them into kg and row numbers
        -- 4a. If the weight is equal to 0, convert to NULL
ALTER TABLE merged_data_cleaned
ADD COLUMN Bag_W INT AFTER Bag_Weight;

UPDATE merged_data_cleaned
SET Bag_W = 
    ( CASE 
      WHEN Bag_Weight LIKE '%lbs%' THEN (Bag_Weight + 0) * 0.45
      WHEN LENGTH(Bag_Weight) > 5 THEN Bag_Weight / Number_of_Bags
      WHEN Bag_Weight LIKE '%kg%' THEN (Bag_Weight + 0)
      WHEN LENGTH(Bag_Weight) <= 2 THEN Bag_Weight
      WHEN Bag_Weight = 0 THEN NULL
      END);

UPDATE merged_data_cleaned
SET 
Bag_W = Null
WHERE Bag_W = 0;

		-- 5. Creating New Column for Total Weight

ALTER TABLE merged_data_cleaned
ADD COLUMN Total_Weight INT AFTER Bag_W;

UPDATE merged_data_cleaned
SET
	Total_Weight = Bag_W * Number_of_Bags;
    
    	-- 6. Remove months from harvest year
		-- Since the column info is too complex, I will hard code

SELECT REGEXP_Replace(harvest_year,"[^0-9]+", '') FROM merged_data_cleaned;    
		-- Column has 45 distinct values
		-- First remove full letters without no numbers

ALTER TABLE merged_data_cleaned
ADD COLUMN harvest INT AFTER harvest_year;

UPDATE merged_data_cleaned
SET harvest_year = null 
WHERE REGEXP_Replace(harvest_year,"[^0-9]+", '')  = '';

        -- Now, hard code each harvest_year
        
UPDATE merged_data_cleaned
SET
	harvest = 
    ( CASE 
		WHEN harvest_year = 'Mar-10' THEN 2010
        WHEN harvest_year = 'Sept 2009 - April 2010' THEN 2009
        WHEN harvest_year = 'Fall 2009' THEN 2009
        WHEN harvest_year = 'December 2009-March 2010' THEN 2009
        WHEN harvest_year = 'Sept 2009 - April 2010' THEN 2009
		WHEN harvest_year = 'Fall 2009' THEN 2009
        WHEN harvest_year = 'Jan-11' THEN 2011
        WHEN harvest_year = '23-Jul-10' THEN 2010
        WHEN harvest_year = 'Abril - Julio /2011' THEN 2011
        WHEN harvest_year = 'Spring 2011 in Colombia.' THEN 2011
        WHEN harvest_year = '08/09 crop' THEN 2008
        WHEN harvest_year = 'March 2010' THEN 2010
        WHEN harvest_year = 'January 2011' THEN 2011
        WHEN LENGTH(harvest_year) = 7 AND harvest_year LIKE '%/%' THEN RIGHT(harvest_year, 4)
        WHEN LENGTH(harvest_year) = 6 AND harvest_year LIKE '%-%' THEN CONCAT(20,RIGHT(harvest_year, 2))
        WHEN LENGTH(harvest_year) >= 9 AND harvest_year LIKE '%/%' THEN LEFT(harvest_year, 4)
        WHEN LENGTH(harvest_year) >= 9 AND harvest_year LIKE '%-%' THEN LEFT(harvest_year, 4)
        WHEN LENGTH(harvest_year) = 7 THEN RIGHT(harvest_year, 4)
        WHEN LENGTH(harvest_year) = 5 AND harvest_year LIKE '%/%' THEN CONCAT(20,RIGHT(harvest_year, 2))
        WHEN LENGTH(harvest_year) = 4 THEN harvest_year
        
        
	END);

       -- 7. Correct grading date and expiration AND save as DATETIME object

UPDATE merged_data_cleaned
SET
grading_date =  STR_TO_DATE(CONCAT(SUBSTRING_INDEX(grading_date,' ', 1), '-', (SUBSTRING_INDEX(SUBSTRING_INDEX(grading_date, ',', 1), ' ', -1)), 
	'-', SUBSTRING_INDEX(grading_date,' ', -1)), '%M-%D-%Y'),
expiration = STR_TO_DATE(CONCAT(SUBSTRING_INDEX(expiration,' ', 1), '-', (SUBSTRING_INDEX(SUBSTRING_INDEX(expiration, ',', 1), ' ', -1)), 
	'-', SUBSTRING_INDEX(expiration,' ', -1)), '%M-%D-%Y') ;
    
		-- Change to DATE TIME
ALTER TABLE `coffee`.`merged_data_cleaned` 
	CHANGE COLUMN `Grading_Date` `Grading_Date` DATETIME NULL DEFAULT NULL ,
	CHANGE COLUMN `Expiration` `Expiration` DATETIME NULL DEFAULT NULL ;

	-- 8. Change foot to meter

UPDATE merged_data_cleaned
SET altitude_low_meters = altitude_low_meters * 0.3048,
	altitude_high_meters = altitude_high_meters * 0.3048,
    altitude_mean_meters = altitude_mean_meters * 0.3048
	WHERE unit_of_measurement = 'ft';

UPDATE merged_data_cleaned
SET unit_of_measurement = 'm'
WHERE unit_of_measurement = 'ft';

    -- 9. Change None to NULL
    
UPDATE merged_data_cleaned
SET color = null
WHERE color = 'None';

	-- SELECT THE DATA FOR AGAIN
SELECT * FROM merged_data_cleaned;


-- PART II - DATA EXPLORATION

	-- 1. How many coffee species are there?
SELECT DISTINCT(COUNT(Species)), Species FROM merged_data_cleaned
	GROUP BY Species;

	-- 2. WHICH OWNERS HAVE MORE COFFEE
SELECT DISTINCT(COUNT(Species)) as Species_Count, Species, `Owner` FROM merged_data_cleaned
	GROUP BY `Owner`, Species
    ORDER BY Species_Count DESC;
    
    -- 3. WHERE ARE THE COFFEE COMING FROM BY SPECIES?
SELECT DISTINCT(COUNT(Species)) AS Species_Count, Species, Country_of_Origin FROM merged_data_cleaned
	GROUP BY Country_of_Origin, Species
    ORDER BY Species_Count DESC;
    
	-- 4. WHICH PRODUCER PRODUCES THE MOST COFFEE
SELECT sum(Total_Weight) AS total_coffee_weight, Producer FROM merged_data_cleaned
	GROUP BY Producer ORDER BY total_coffee_weight DESC;    

	-- 5. WHICH MILL HAD THE HIGHEST AMOUNT OF COFFEE BY YEARS
SELECT sum(Total_Weight) AS total_coffee_weight, mill, harvest FROM merged_data_cleaned
	GROUP BY mill, harvest ORDER BY total_coffee_weight DESC;

    -- 6. WHICH COUNTRY AND REGION PRODUCED THE MOST COFFEE
SELECT sum(Total_Weight) as total_coffee_weight, Country_of_Origin, Region FROM merged_data_cleaned
	GROUP BY Country_of_Origin, Region ORDER BY total_coffee_weight DESC;

    -- 7. WHICH COUNTRY PRODUCED THE MOST COFFEE

SELECT sum(Total_Weight) as total_coffee_weight, COUNT(Country_of_Origin) as Total, Country_of_Origin 
FROM merged_data_cleaned
GROUP BY Country_of_Origin ORDER BY total_coffee_weight DESC;
    
    -- 8. WHAT IS THE MEAN TIME OF GRADING AFTER HARVESTING
SELECT AVG(YEAR(Grading_Date) - (harvest)) AS grading_time FROM merged_data_cleaned
		WHERE Grading_Date IS NOT NULL and Harvest IS NOT NULL;
        
    -- 9. HOW WERE THE COFFEE PROCESSED
SELECT DISTINCT(COUNT(Processing_Method)) as method_count, Processing_Method from merged_data_cleaned
	WHERE Processing_Method IS NOT NULL GROUP BY Processing_Method ;
    
    -- 10. BEST COFFEE AMONG ALL - BY ALL FEATURES
SELECT Species, Owner, Company, Total_Cup_Points, aroma, Flavor, Aftertaste, Acidity, Body, Balance, Uniformity,
Clean_cup, Sweetness, Cupper_Points FROM merged_data_cleaned ORDER BY total_cup_points DESC LIMIT 20;

    -- 11. IN WHAT HIGHT COFFEE GROWN?
SELECT AVG(altitude_low_meters), AVG(altitude_high_meters), species FROM merged_data_cleaned
	GROUP BY species;
    
    -- 12. WHAT IS THE RELATIONSHIP BETWEEN ALTITUDE AND COFFEE QUALITY?
SELECT Species, Owner, Company, total_cup_points, aroma, flavor, aftertaste, acidity, body, balance, uniformity,
	clean_cup, sweetness, cupper_points, altitude_low_meters, altitude_high_meters FROM merged_data_cleaned
	ORDER BY total_cup_points DESC LIMIT 20;
    
	-- 13. DOES YEAR HAVE RELATIONSHIP WITH QUALITY

SELECT species, harvest, AVG(total_cup_points) as Total_Points FROM merged_data_cleaned
GROUP BY species, harvest ORDER by Total_Points DESC;

	-- 14. DOES ORIGIN EFFECTS GRADING TIME

SELECT species, country_of_origin, AVG(YEAR(Grading_Date) - (harvest)) AS grading_time FROM merged_data_cleaned
GROUP BY country_of_origin, species
ORDER BY grading_time DESC;

	-- 15. DOES COLOR EFFECT QUALITY

SELECT Species, Color, AVG(total_cup_points) as total_points FROM merged_data_cleaned
GROUP BY Species, Color
ORDER BY total_points DESC;
	
    -- 16. DOES PROCESS METHOD EFFECT QUALITY

SELECT Species, Processing_Method, AVG(total_cup_points) as total_points FROM merged_data_cleaned
GROUP BY Species, Processing_Method
ORDER BY total_points DESC;


    




















