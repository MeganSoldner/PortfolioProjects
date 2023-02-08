--COVID-19 Data Exploration


SELECT * FROM CovidDeaths
ORDER BY 3,4;

SELECT * FROM CovidVaccinations
ORDER BY 3,4;


--Select data that will be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--total cases vs. total deaths (if you live in afghanistan on this day you have this % of dying if you have covid) --could do death percentage in united states
--shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--total cases vs. population
--shows what percentage of population got covid
SELECT location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 AS populationInfectedPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--countries with highest infection rate vs. population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS populationInfectedPercentage
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY populationInfectedPercentage DESC;



--countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount FROM CovidDeaths ---problem with total_deaths data type when read by agg function
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--death count BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount FROM CovidDeaths ---problem with total_deaths data type when read by agg function
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidDeaths ---problem with total_deaths data type when read by agg function
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS
SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100
--newcases doesnt refer to specific area(continent), its over new cases --new deaths var char
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--across the world death percentage is a little over 2%
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100
--newcases doesnt refer to specific area(continent), its over new cases --new deaths var char
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,

FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USING CTE
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac;

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacctinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated;


--Creating view to store data for later visulizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
