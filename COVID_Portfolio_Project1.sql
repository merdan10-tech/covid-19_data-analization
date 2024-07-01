SELECT *
FROM DA_Project1_Covid_Cases..CovidDeaths
ORDER BY 3,4 --this sorts by 3rd and 4th columns (location&date)

--SELECT *
--FROM DA_Project1_Covid_Cases..CovidVaccinations
--ORDER BY 3,4

-- Visually see the columns that I work with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM DA_Project1_Covid_Cases..CovidDeaths
ORDER BY 1,2

-- Examine Total cases vs. Total Deaths
-- Shows likelihood of death percentage according to the country and total cases

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) AS death_percentage
FROM DA_Project1_Covid_Cases..CovidDeaths
ORDER BY 1,2


-- Examine Total Cases vs Population
-- Visually demonstrates the percentage of population infected by COVID-19

SELECT location, date, population, total_cases, ROUND((total_cases/population) * 100, 6) AS case_ratio
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Depicted countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM DA_Project1_Covid_Cases..CovidDeaths
GROUP BY location, population
ORDER BY percent_of_infected DESC

-- Demonstrated countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS ultimate_total_deaths
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY ultimate_total_deaths DESC

--Total Death Number by Continent
SELECT continent, MAX(cast(total_deaths AS int)) AS ultimate_total_deaths
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ultimate_total_deaths DESC


--Global Death Percentage Per Day
SELECT date, SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Death Percentage All over the World
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Implementation of SECOND TABLE

-- Inspect Vaccination being used by amount of People

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM DA_Project1_Covid_Cases..CovidDeaths AS d
JOIN DA_Project1_Covid_Cases..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--Examine Daily Percentage of vaccinated over population  

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM DA_Project1_Covid_Cases..CovidDeaths AS d
JOIN DA_Project1_Covid_Cases..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 
WHERE d.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population) * 100 AS percentage_of_vaccinated
FROM PopvsVac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM DA_Project1_Covid_Cases..CovidDeaths AS d
JOIN DA_Project1_Covid_Cases..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 

SELECT *, (rolling_people_vaccinated/population) * 100 AS percentage_of_vaccinated
FROM #PercentPopulationVaccinated


-- Create View To Store Data For Later Visualizations

CREATE VIEW PercentPopulationVaccinated  AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM DA_Project1_Covid_Cases..CovidDeaths AS d
JOIN DA_Project1_Covid_Cases..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 
WHERE d.continent IS  NOT NULL
--order by 2,3


-- Testing the view
SELECT *
FROM PercentPopulationVaccinated





--TEMP TABLE 2

DROP TABLE IF EXISTS #DeathPercentageByCountry

CREATE TABLE #DeathPercentageByCountry (
	location nvarchar(255),
	date datetime,
	total_cases numeric,
	total_deaths numeric,
	death_percentage numeric
)

INSERT INTO #DeathPercentageByCountry
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) AS death_percentage
FROM DA_Project1_Covid_Cases..CovidDeaths
ORDER BY 1,2

--Separate the batch with GO
GO	 


--Create a Table View 2
CREATE VIEW DeathPercentageByCountry  AS 
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) AS death_percentage
FROM DA_Project1_Covid_Cases..CovidDeaths
--ORDER BY 1,2


--Testing the View Table 2
SELECT *
FROM DeathPercentageByCountry






--TEMP TABLE 3

DROP TABLE IF EXISTS #PercentOfInfectedByCountry

CREATE TABLE #PercentOfInfectedByCountry (
	location nvarchar(255),
	population numeric,
	ultimate_total_cases numeric,
	percent_of_infected numeric
)

INSERT INTO #PercentOfInfectedByCountry
SELECT location, population, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM DA_Project1_Covid_Cases..CovidDeaths
GROUP BY location, population
ORDER BY percent_of_infected DESC

--Separate the batch with GO
GO	 

--Create a Table View 3
CREATE VIEW PercentOfInfectedByCountry  AS 
SELECT location, population, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM DA_Project1_Covid_Cases..CovidDeaths
GROUP BY location, population

--Testing the View Table 3
SELECT *
FROM PercentOfInfectedByCountry






--TEMP TABLE 4

DROP TABLE IF EXISTS #GlobalDeathRatio

CREATE TABLE #GlobalDeathRatio (
	global_cases numeric,
	global_deaths numeric,
	global_death_ratio numeric
)

INSERT INTO #GlobalDeathRatio
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Separate the batch with GO
GO	 

--Create a Table View 4
CREATE VIEW GlobalDeathRatio  AS 
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM DA_Project1_Covid_Cases..CovidDeaths
WHERE continent IS NOT NULL

--Testing the View Table 4
SELECT *
FROM GlobalDeathRatio



