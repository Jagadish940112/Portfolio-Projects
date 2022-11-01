-- Check CovidDeaths
SELECT *
FROM dbo.CovidDeaths
ORDER BY location, date

-- Check CovidVaccinations
SELECT *
FROM dbo.CovidVaccinations
ORDER BY location, date

-- Select Columns that will be used for CovidDeaths
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM dbo.CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths
-- Shows probability of dying if contract Covid-19 in specific country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY location, date

-- Total Cases vs Population
-- Shows percentage of population infected by Covid-19
SELECT location, date, population, total_cases, (total_cases/population)*100 as Infected_Population_Percentage
FROM dbo.CovidDeaths
Where location like '%states%'
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as Max_Cases, MAX((total_cases/population))*100 as Highest_Infection_Percentage
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY Highest_Infection_Percentage DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
-- to check Data Types, go to Tables, Columns
-- order not correct due to column being nvarchar instead of integer
-- convert/case column to integer

-- Break down by Continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY Total_Cases

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY location,date

-- CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinationsCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
)

SELECT *, (RollingVaccinationsCount/Population)*100
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
RollingVaccinationsCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY location,date

SELECT *, (RollingVaccinationsCount/Population)*100 as PopulationVaccinatedPercenatge
FROM #PercentPopulationVaccinated

-- Views for Visualization later
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingVaccinationsCount
FROM CovidDeaths as dea
Join CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea. date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY location,date

SELECT *
FROM PercentPopulationVaccinated