/*
Queries used for Tableau Project
*/

--1. Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is NOT NULL

--2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
WHERE continent is NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- 3.
-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as MaxCases, MAX((total_cases/population))*100 as HighestInfectionPercentage
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC

-- 4.
SELECT location, population, date, MAX(total_cases) as MaxCases, Max((total_cases/population))*100 as HighestInfectionPercentage
FROM dbo.CovidDeaths
GROUP BY location, population, date
ORDER BY HighestInfectionPercentage desc
