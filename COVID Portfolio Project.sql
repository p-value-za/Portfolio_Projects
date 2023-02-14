-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contracting COVID-19 in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID-19
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfections, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with the highest death count per population 
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null   
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death counts
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null   
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths as int)) AS TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null   
GROUP BY date
ORDER BY 1,2




-- JOIN THE COVID DEATHS AND THE COVID VACCINATION TABLES

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE (COMMON TABLE EXPRESSION)
-- CTE used to do further calculations using calculated column

WITH PopVsVac (continent, Location, Date, Population, new_vaccinations, TotalVaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (TotalVaccinations/Population)*100 AS PercentageVaccinated
FROM PopVsVac;


-- USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (TotalVaccinations/Population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

