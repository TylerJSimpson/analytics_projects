--Query created on Google BigQuery

----------------------
--CHECKING DATA IMPORT
----------------------

--Checking if tables were imported correctly

SELECT *
FROM `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
ORDER BY 3,4
;
SELECT *
FROM `covid-project-dec2021.covid_dataset_dec2021.covid-vaccinations`
ORDER BY 3,4
;

---------------------------
--EXPLORATORY DATA ANALYSIS
---------------------------

--Selecting appropriate data from tables, order by location then date

SELECT
    location, date, total_cases, new_cases, total_deaths, population
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
ORDER BY 1,2
;

--Checking unique locations to find USA syntax

SELECT 
    DISTINCT location
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
;

--Total cases vs total deaths exploration
--Chance of dying in the US by time

SELECT
    location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE location LIKE '%States%'
ORDER BY 1,2
;

--Total cases vs population exploration
--Covid infection rate in the US

SELECT
    location, date, total_cases, population, (total_cases/population)*100 as cases_per_population
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE location LIKE '%States%'
ORDER BY 1,2
;

--Countries with highest infection count exploration

SELECT
    location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as cases_per_population
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
GROUP BY location, population
ORDER BY cases_per_population DESC
;

--Countries with highest death count exploration

SELECT 
    location, MAX(total_deaths) as total_death_count
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC
;

--Locations with highest death count exploration
--Got rid of locations that were financial and political

SELECT 
    location, MAX(total_deaths) as total_death_count
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NULL
    AND location NOT LIKE '%income%'
    AND location NOT LIKE '%Union%'
GROUP BY location
ORDER BY total_death_count DESC
;

--Global data exploration
--Global day by day new cases, new deaths, and % of new deaths vs new cases

SELECT
    date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as newdeaths_vs_newcases
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
;

--Global data further exploration

SELECT
    SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as newdeaths_vs_newcases
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2
;

--Joining tables

SELECT
    dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_vaccinated_people,
FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths` dea
JOIN
    `covid-project-dec2021.covid_dataset_dec2021.covid-vaccinations` vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
;

--Creating temp table

CREATE TEMP TABLE percentpopulationvaccinated
AS
SELECT
    dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_vaccinated_people,

FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths` dea
JOIN
    `covid-project-dec2021.covid_dataset_dec2021.covid-vaccinations` vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

;

--Creating view for visualization

CREATE VIEW covid_dataset_dec2021.percentpopulationvaccinated AS
SELECT
    dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_vaccinated_people,

FROM
    `covid-project-dec2021.covid_dataset_dec2021.covid-deaths` dea
JOIN
    `covid-project-dec2021.covid_dataset_dec2021.covid-vaccinations` vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
;

--Checking view

SELECT
    *
FROM 
    covid_dataset_dec2021.percentpopulationvaccinated
;
