/*
Steps to Complete

    Create a View called “forestation” by joining all three tables - forest_area,
     land_area and regions in the workspace.
    The forest_area and land_area tables join on both country_code AND year.
    The regions table joins these based on only country_code.

    In the ‘forestation’ View, include the following:
        All of the columns of the origin tables
        A new column that provides the percent of the land area that is designated as forest.

    Keep in mind that the column forest_area_sqkm in the forest_area table and the land_area_sqmi
    in the land_area table are in different units (square kilometers and square miles, respectively),
    so an adjustment will need to be made in the calculation you write (1 sq mi = 2.59 sq km).
*/

CREATE VIEW forestation AS
SELECT f.country_code AS country_code, f.country_name AS country_name,
f.year AS year, f.forest_area_sqkm AS forest_area_sqkm,
l.total_area_sq_mi AS total_area_sq_mi, r.region AS region,
r.income_group AS income_group,
(f.forest_area_sqkm/(l.total_area_sq_mi*2.59))*100 AS percent_forest
FROM forest_area AS f, land_area AS l, regions AS r
WHERE f.country_code = l.country_code AND f.year = l.year
AND l.country_code = r.country_code;

/*
1. GLOBAL SITUATION

Instructions:

    Answering these questions will help you add information into the template.
    Use these questions as guides to write SQL queries.
    Use the output from the query to answer these questions.

1a. What was the total forest area (in sq km) of the world in 1990?
   Please keep in mind that you can use the country record denoted as “World" in the region table.

1b. What was the total forest area (in sq km) of the world in 2016?
   Please keep in mind that you can use the country record in the table is denoted as “World.”

*/
SELECT country_name, year, forest_area_sqkm
FROM forestation
WHERE country_name='World' AND (YEAR='1990' OR YEAR='2016')
ORDER BY year ASC;
/* results
country_name	year	  forest_area_sqkm
World	        1990	  41282694.9
World	        2016	  39958245.9
*/


/*
1c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
*/
SELECT (t1.forest_area_sqkm - t0.forest_area_sqkm) AS abs_change_sq_km
FROM forestation AS t1, forestation AS t0
WHERE t1.year = '2016' AND t1.country_name = 'World'
AND   t0.year = '1990' AND t0.country_name = 'World';
/* results
abs_change_sq_km
-1324449
*/

/*
1d. What was the percent change in forest area of the world between 1990 and 2016?
*/
SELECT (((t1.forest_area_sqkm / t0.forest_area_sqkm)-1)*100) AS percent_change_forestArea
FROM forestation AS t1, forestation AS t0
WHERE t1.year = '2016' AND t1.country_name = 'World'
AND   t0.year = '1990' AND t0.country_name = 'World';
/* results
percent_change_forestarea
-3.20824258980245
*/

/*
1e. If you compare the amount of forest area lost between 1990 and 2016,
   to which country's total area in 2016 is it closest to?
*/
SELECT country_name, (total_area_sq_mi*2.59) AS total_area_sq_km
FROM forestation
WHERE year='2016' AND (total_area_sq_mi*2.59)>1270000 AND (total_area_sq_mi*2.59)<1324449;
/* results
country_name	total_area_sq_km
Peru	        1279999.9891
*/


/*
2. REGIONAL OUTLOOK

2a. What was the percent forest of the entire world in 2016?
   Which region had the HIGHEST percent forest in 2016,
   and which had the LOWEST, to 2 decimal places?

2b. What was the percent forest of the entire world in 1990?
   Which region had the HIGHEST percent forest in 1990,
   and which had the LOWEST, to 2 decimal places?

2c. Based on the table you created, which regions of the world
    DECREASED in forest area from 1990 to 2016?
*/

SELECT t0.region, t0.country_name, t0.forest_area_sqkm AS forest_area_1990
FROM forestation t0;
SELECT ROUND(CAST((region_forest_1990/region_area_1990)*100 AS NUMERIC),2)
AS forest_cover_1990,
ROUND(CAST((region_forest_2016/region_area_2016)*100 AS NUMERIC),2)
AS forest_cover_2016, region
FROM (SELECT SUM(t0.forest_area_sqkm) AS region_forest_1990,
      SUM (t0.total_area_sq_mi*2.59) AS region_area_1990, t0.region,
      SUM (t1.forest_area_sqkm) AS region_forest_2016,
      SUM (t1.total_area_sq_mi*2.59) AS region_area_2016
FROM forestation t0, forestation t1
      WHERE t0.year ='1990'
      AND t1.year ='2016'
      AND t0.region = t1.region
GROUP BY t0.region) region_percent
ORDER BY forest_cover_1990 DESC;
/*
Output
8 results
Download CSV
forest_cover_1990	forest_cover_2016	region
51.0	            46.2	            Latin America & Caribbean
37.3	            38.0	            Europe & Central Asia
35.7	            36.0	            North America
32.4	            31.4	            World
30.7	            28.8	            Sub-Saharan Africa
25.8	            26.4	            East Asia & Pacific
16.5	            17.5	            South Asia
1.8	               2.1	            Middle East & North Africa
*/

/*
3. COUNTRY-LEVEL DETAIL
A.	SUCCESS STORIES
*/
SELECT t1.country_name, t1.region,
ROUND(CAST(((t1.forest_area_sqkm-t0.forest_area_sqkm)) AS NUMERIC),2)
AS change_forestArea_sqkm
FROM forestation AS t1
JOIN forestation AS t0
ON (t1.year='2016' AND t0.year='1990')
AND t1.country_code = t0.country_code
WHERE t1.country_name !='World'
AND t1.forest_area_sqkm !=0 AND t0.forest_area_sqkm !=0
ORDER BY change_forestArea_sqkm DESC
Limit 5;
/*
Output
5 results
country_name	         region	                    change_forestarea_sqkm
China	                 East Asia & Pacific	      527229.06
United States	         North America	             79200.00
India	                 South Asia	                 69213.98
Russian Federation	   Europe & Central Asia	     59395.00
Vietnam	               East Asia & Pacific	       55390.00
*/

/*
Which 5 countries saw the largest absolute decrease in forest area from 1990 to 2016?
What was the sqkm change for each?
*/
SELECT t1.country_name, t1.region,
ROUND(CAST(((t1.forest_area_sqkm-t0.forest_area_sqkm)) AS NUMERIC),2)
AS change_forestArea_sqkm
FROM forestation AS t1
JOIN forestation AS t0
ON (t1.year='2016' AND t0.year='1990')
AND t1.country_code = t0.country_code
WHERE t1.country_name !='World'
ORDER BY change_forestArea_sqkm ASC
Limit 5;
/*
Output
5 results
country_name	region	                     change_forestarea_sqkm
Brazil	      Latin America & Caribbean	   -541510.00
Indonesia	    East Asia & Pacific	         -282193.98
Myanmar	      East Asia & Pacific	         -107234.00
Nigeria	      Sub-Saharan Africa	         -106506.00
Tanzania	    Sub-Saharan Africa	         -102320.00
*/



/*
Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016?
What was the percent change to 2 decimal places for each?
*/
SELECT t1.country_name, t1.region,
ROUND(CAST(((t1.forest_area_sqkm/t0.forest_area_sqkm-1)*100) AS NUMERIC),2)
AS percent_change_forestArea
FROM forestation AS t1
JOIN forestation AS t0
ON (t1.year='2016' AND t0.year='1990')
AND t1.country_code = t0.country_code
ORDER BY percent_change_forestArea ASC
Limit 5;
/*
Output
5 results
country_name	region	                    percent_change_forestarea
Togo	        Sub-Saharan Africa	        -75.45
Nigeria	      Sub-Saharan Africa	        -61.80
Uganda	      Sub-Saharan Africa	        -59.13
Mauritania	  Sub-Saharan Africa	        -46.75
Honduras	    Latin America & Caribbean	  -45.03
*/



/*
Country with largest percent change in forest area from 1990 to 2016
*/
SELECT t1.country_name, t1.region,
ROUND(CAST(((t1.forest_area_sqkm/(t0.forest_area_sqkm+0.01)-1)*100) AS NUMERIC),2)
AS percent_change_forestArea
FROM forestation AS t1
JOIN forestation AS t0
ON (t1.year='2016' AND t0.year='1990')
AND t1.country_code = t0.country_code
WHERE t0.forest_area_sqkm != 0 AND t1.forest_area_sqkm != 0
ORDER BY percent_change_forestArea DESC
LIMIT 1;
/*
Output
1 results
country_name	    region	                   percent_change_forestarea
Iceland	          Europe & Central Asia	     213.65
*/

/*
c. If countries were grouped by percent forestation in quartiles,
which group had the most countries in it in 2016?
*/
With tab1 AS
(SELECT country_name, year,forest_area_sqkm, total_area_sq_mi*2.59
  AS total_area_sqkm, percent_forest
FROM forestation
WHERE  (year='2016' AND country_name!='World'
        AND forest_area_sqkm !=0 AND total_area_sq_mi!=0)
ORDER BY percent_forest DESC),

tab2 AS
(SELECT tab1.country_name, tab1.year, tab1.percent_forest,
  CASE WHEN tab1.percent_forest > 75 THEN 4
  WHEN tab1.percent_forest <= 75 AND tab1.percent_forest > 50 THEN 3
  WHEN tab1.percent_forest <= 50 AND tab1.percent_forest > 25 THEN 2
  ELSE 1
  END AS percentile
  FROM tab1 ORDER BY 4 DESC)

SELECT tab2.percentile, COUNT(tab2.percentile)
FROM tab2
GROUP BY 1
ORDER BY 2 DESC;
/*
Output
4 results
percentile	count
1	          85
2	          72
3	          38
4	           9
*/

/*
d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
*/
SELECT country_name, region, year,forest_area_sqkm, total_area_sq_mi*2.59 AS total_area_sqkm,
ROUND(CAST((percent_forest) AS NUMERIC),2) AS percent
FROM forestation
WHERE  (year='2016' AND country_name!='World'
        AND forest_area_sqkm !=0 AND total_area_sq_mi!=0)
        AND percent_forest > 75
ORDER BY percent_forest DESC;

/*
Output
9 results
country_name	          region	                  year	forest_area_sqkm	   total_area_sqkm	   percent
Suriname	              Latin America & Caribbean	2016	153282.002	         155999.9994	       98.26
Micronesia, Fed. Sts.	  East Asia & Pacific	      2016	643.0000305	         699.9993	           91.86
Gabon	                  Sub-Saharan Africa	      2016	232000	             257670.0091	       90.04
Seychelles	            Sub-Saharan Africa	      2016	406.6999817	         460.0099	           88.41
Palau	                  East Asia & Pacific	      2016	402.9999924	         460.0099	           87.61
American Samoa	        East Asia & Pacific	      2016	175	                 199.9998	           87.50
Guyana	                Latin America & Caribbean	2016	165160	             196849.9974	       83.90
Lao PDR	                East Asia & Pacific	      2016	189505.8008	         230800.0023	       82.11
Solomon Islands	        East Asia & Pacific	      2016	21793.99902	         27990.0005	         77.86

*/

/*
e. How many countries had a percent forestation higher than the United States in 2016?
*/
With tab1 AS
(SELECT country_name, year,forest_area_sqkm, total_area_sq_mi*2.59
  AS total_area_sqkm, percent_forest
  FROM forestation
  WHERE  (year='2016' AND country_name!='World'
        AND forest_area_sqkm !=0 AND total_area_sq_mi!=0)
  ORDER BY percent_forest DESC)

SELECT COUNT(tab1.country_name)
FROM tab1
WHERE tab1.percent_forest > (SELECT tab1.percent_forest
  FROM tab1
  WHERE tab1.country_name = 'United States');
/*
  Output
  1 results
  count
  94
*/
