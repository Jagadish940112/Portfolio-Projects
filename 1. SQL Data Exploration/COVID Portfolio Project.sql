/*
COVID-19 Data Exploration
Data from https://ourworldindata.org/coronavirus (1/1/2020 - 30/4/2021)
Skills used: JOINs, CTE, Temp Table, Window Functions, Aggregate Functions, Creating View, Converting Data Types
*/

-- Check CovidDeaths Table
SELECT *
FROM dbo.CovidDeaths
ORDER BY location, date

-- Check CovidVaccinations Table
SELECT *
FROM dbo.CovidVaccinations
ORDER BY location, date

-- Select Columns that will be used for CovidDeaths
SELECT continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
FROM dbo.CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths
-- Shows probability of dying if contract COVID-19 in specific country by day
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY location, date

-- Total Cases vs Population
-- Shows percentage of population infected by COVID-19 in a specific country by day
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as MaxCases, MAX((total_cases/population))*100 as HighestInfectionPercentage
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
-- some rows have missing continent value resulting in location being used as continent
-- example; Continent:NULL | Location: Africa
GROUP BY location
ORDER BY TotalDeathCount DESC
-- to check Data Types, go to Tables, Columns
-- order not correct due to total_deaths column being nvarchar instead of integer
-- convert/case total_deaths column to integer

-- Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
-- TotalCases/Deaths <> total_cases/deaths = accumulated new_cases/deaths over time in one country, will reset when in new country
-- new_deaths data type is nvarchar, convert to integer
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL

-- Total Population vs Vaccinations
-- Shows Cumulative of Vaccinations Count in a Country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date)
as CumulativeVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY location, date

-- Using CTE to perform Calculation on Partition By in previous query
-- Shows the Cumulative Percentage of Population got Vaccinated
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, CumulativeVaccinationsCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date)
as CumulativeVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
)

SELECT *, (CumulativeVaccinationsCount/Population)*100 as PopulationVaccinatedPercentage
FROM PopvsVac

-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinationsCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date)
as CumulativeVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY Location, Date

SELECT *, (CumulativeVaccinationsCount/Population)*100 as PopulationVaccinatedPercentage
FROM #PercentPopulationVaccinated

-- Views for Visualization later
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.date)
as CumulativeVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL

SELECT *
FROM PercentPopulationVaccinated