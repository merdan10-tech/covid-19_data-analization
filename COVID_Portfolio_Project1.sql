-- Our first dataset check
SELECT *
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4 --this sorts by 3rd and 4th columns (location&date)


-- Examine Total cases vs. Total Deaths
-- Calculate the death percentage for each country and date it
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) AS death_percentage
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2


-- Examine Total Cases vs Population
-- Depict the percentage of population infected by COVID-19
SELECT location, date, population, total_cases, ROUND((total_cases/population) * 100, 6) AS case_ratio
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2


-- Demonstrate Countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS ultimate_total_deaths
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY ultimate_total_deaths DESC


-- Total Death Number by Continent
SELECT continent, MAX(cast(total_deaths AS int)) AS ultimate_total_deaths
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ultimate_total_deaths DESC


-- Calculate the Global Death Percentage Per Day
SELECT date, SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- THIS QUERY WAS USED FOR TABLEAU VIZUALIZATION 1

--Total Death Percentage All over the World
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_percentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- THIS QUERY WAS USED FOR TABLEAU VIZUALIZATION 2	

-- Calculate the total number of deaths for locations without a specified continent, 
-- excluding aggregate entities like 'World', 'European Union', and 'International'
SELECT location, SUM(cast(new_deaths as int)) AS total_death_count
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC


-- THIS QUERY WAS USED FOR TABLEAU VIZUALIZATION 3

-- Display countries with the highest infection rate as a percentage of their population
SELECT location, population, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
ORDER BY percent_of_infected DESC


-- THIS QUERY WAS USED FOR TABLEAU VIZUALIZATION 4

-- Calculate the highest infection rate as a percentage of population for each location and date
SELECT location, population, date, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population, date
ORDER BY percent_of_infected DESC



-- Implementation of SECOND TABLE

-- Inspect Vaccination being used by amount of People
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM PortfolioProjects..CovidDeaths AS d
JOIN PortfolioProjects..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 
WHERE d.continent IS NOT NULL
ORDER BY 2,3


--Examine Daily Percentage of vaccinated over population  
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM PortfolioProjects..CovidDeaths AS d
JOIN PortfolioProjects..CovidVaccinations AS v
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
FROM PortfolioProjects..CovidDeaths AS d
JOIN PortfolioProjects..CovidVaccinations AS v
ON d.location = v.location AND d.date = v.date 

SELECT *, (rolling_people_vaccinated/population) * 100 AS percentage_of_vaccinated
FROM #PercentPopulationVaccinated


-- Create View To Store Data For Later Visualizations
CREATE VIEW PercentPopulationVaccinated  AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM PortfolioProjects..CovidDeaths AS d
JOIN PortfolioProjects..CovidVaccinations AS v
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
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

--Separate the batch with GO
GO	 


--Create a Table View 2
CREATE VIEW DeathPercentageByCountry  AS 
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) AS death_percentage
FROM PortfolioProjects..CovidDeaths
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
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
ORDER BY percent_of_infected DESC

--Separate the batch with GO
GO	 

--Create a Table View 3
CREATE VIEW PercentOfInfectedByCountry  AS 
SELECT location, population, MAX(total_cases) AS ultimate_total_cases, ROUND(MAX((total_cases/population))* 100, 6) AS percent_of_infected
FROM PortfolioProjects..CovidDeaths
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
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Separate the batch with GO
GO	 

--Create a Table View 4
CREATE VIEW GlobalDeathRatio  AS 
SELECT SUM(new_cases) AS global_cases, SUM(cast(new_deaths as int)) AS global_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS global_death_ratio
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL

--Testing the View Table 4
SELECT *
FROM GlobalDeathRatio



