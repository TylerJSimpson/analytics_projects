---------------------------
--FOR TABLEAU VISUALIZATION
---------------------------

--Visualization 1

SELECT
    SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as newdeaths_vs_newcases
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2
;

--Visualization 2

SELECT 
    location, SUM(new_deaths) as total_new_deaths
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_new_deaths DESC
;

--Visualization 3

SELECT
    location, population, MAX(total_cases) as highest_case_count, MAX((total_cases/population)*100) as percent_population_cases
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
GROUP BY location, population
ORDER BY percent_population_cases
;

--Visualization 4

SELECT
    location, population, date, MAX(total_cases) as highest_case_count, MAX((total_cases/population)*100) as percent_population_cases
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
GROUP BY location, population, date
ORDER BY percent_population_cases
;
