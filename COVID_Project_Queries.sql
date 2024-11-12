SELECT *
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PORTFOLIO..CovidVaccinations
ORDER BY 3,4

-- VERIFYING DATA

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PORTFOLIO..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES vs DEATHS (Likelihood of dying after contracting COVID)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- TOTAL CASES vs POPULATION

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PORTFOLIO..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- HIGHEST INFECTION RATE VS POPULATION

SELECT location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentagePopInfected
FROM PORTFOLIO..CovidDeaths
GROUP BY location, population
order by PercentagePopInfected desc

-- HIGHEST DEATH COUNTS PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

-- DEATHS BROKEN DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc

-- GLOBAL NUMBERS (TOTAL %)

SELECT SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) as Total_New_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- GLOBAL NUMBERS (BY DATE)

SELECT date, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) as Total_New_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--LOOKING FOR TOTAL POPULATION vs VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by  dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVacc
, 
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacc)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by  dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVacc
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVacc/population)*100
FROM PopvsVac

-- USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVacc numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by  dea.location ORDER BY dea.location,
 dea.date) as RollingPeopleVacc
FROM PORTFOLIO..CovidDeaths dea
JOIN PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (RollingPeopleVacc/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE DATA FOR TABLEAU VISUALIZATION


-- 1

CREATE VIEW PercentPopulationVacc AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVacc
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

-- 2

CREATE VIEW GlobalNumbersByDate AS

SELECT date, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) as Total_New_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PORTFOLIO..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date

-- 3

CREATE VIEW DeathByPopulation AS

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null
GROUP BY location