SELECT *
FROM iqradb..CovidDeaths
WHERE continent IS NULL
ORDER BY location, date

--SELECT *
--FROM iqradb..CovidVaccinations
-- WHERE continent is not null
--ORDER BY location, date

-- Select location, date, total_cases, new_cases, total_deaths, population
-- FROM iqradb..CovidDeaths
-- Order by 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
-- Select location, date, total_cases, total_deaths, 
-- (convert(float,total_deaths)/Nullif(Convert(float,total_cases),0))*100 AS DeathPercentage
-- FROM iqradb..CovidDeaths
--WHERE location LIKE '%states%' and continent is not null
--Order by 1,2

-- looking at the total cases vs Population
-- Shows what percentage of population got covid

-- Select location, date, total_cases, population,
--(convert(float,total_cases)/population)*100 AS PercentPopulationInfected
--FROM iqradb..CovidDeaths
-- WHERE location LIKE '%states%'
-- Order by 1,2

-- Looking at Companies with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectedCount,
MAX((convert(float,total_cases)/Nullif(Convert(float,population),0))) *100 AS PercentPopulationInfected
FROM iqradb..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as bigint)) AS total_deathcounts
FROM iqradb..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL --	makes sure it is not missing
  AND continent <> '' -- makes sure it's not just an empty text
GROUP BY location
Order by total_deathcounts desc

--Showing continents with the highest deathcount per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM iqradb..CovidDeaths
WHERE continent IS NOT NULL --	makes sure it is not missing
  AND continent <> '' -- makes sure it's not just an empty text
GROUP BY continent
Order by TotalDeathCount desc 

-- GLOBAL NUMBERS

SELECT 
    date, 
    SUM(CAST(new_cases AS float)) AS total_cases, 
    SUM(CAST(new_deaths AS float)) AS total_deaths, 
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 AS DeathPercentage
FROM 
    iqradb..CovidDeaths
WHERE 
    continent IS NOT NULL
    AND continent <> ''
GROUP BY 
    date
ORDER BY 
    date;


-- Total Cases

SELECT 
    SUM(CAST(new_cases AS float)) AS total_cases, 
    SUM(CAST(new_deaths AS float)) AS total_deaths, 
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100 AS DeathPercentage
FROM 
    iqradb..CovidDeaths
WHERE 
    continent IS NOT NULL
    AND continent <> ''
-- GROUP BY date
ORDER BY 
    1,2;


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM iqradb..CovidDeaths as dea
JOIN iqradb..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
Order by 2,3;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM iqradb..CovidDeaths as dea
JOIN iqradb..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
Order by 2,3;

 
 -- USE CTE
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM iqradb..CovidDeaths as dea
JOIN iqradb..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Nullif(Convert(float,population),0))*100
FROM PopvsVac



-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255), 
Date datetime, 
Population FLOAT, 
New_vaccinations FLOAT, 
RollingPeopleVaccinated FLOAT
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM iqradb..CovidDeaths as dea
JOIN iqradb..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- Order by 2,3

SELECT *, (RollingPeopleVaccinated/Nullif(Convert(float,population),0))*100
FROM #PercentPopulationVaccinated

--CREATE VIEW
USE iqradb;
GO
Create View PopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM iqradb..CovidDeaths as dea
JOIN iqradb..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ''
-- Order by 2,3