/*SELECT * FROM Covid..CovidDeaths
ORDER BY 3,4

SELECT * FROM Covid..CovidVaccinations
ORDER BY 3,4


Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



-- select data that will be used

SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
ORDER BY 1, 2

-- total Cases VS Total Deaths

-- demonstrates likelihood of death if you contract covid in your country

SELECT location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- total cases VS population

-- percentage of population that got Covid

SELECT location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulation
FROM Covid..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulation
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulation DESC

-- countries with the highest death count per population

SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BROKEN DOWN BY CONTINENT

-- showing Continents with highest amount of deaths per population

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Global Numbers

-- Global deaths by date

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float ))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From Covid..CovidDeaths
where continent is not null 
GROUP by date
order by 1,2

-- global death totals

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float ))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From Covid..CovidDeaths
where continent is not null 
order by 1,2


-- total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(vacs.new_vaccinations) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingTotalVaccinations
FROM covid..CovidDeaths deaths
JOIN covid..CovidVaccinations vacs
    ON deaths.location = vacs.Location
    AND deaths.date = vacs.date 
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

-- CTE for Populatiion Vs Vaccinations

WITH PopVsVacs (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(vacs.new_vaccinations) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingTotalVaccinations
FROM covid..CovidDeaths deaths
JOIN covid..CovidVaccinations vacs
    ON deaths.location = vacs.Location
    AND deaths.date = vacs.date 
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingTotalVaccinations/population)*100
FROM PopVsVacs

-- TEMP Table for Populations Vs vaccinations

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date date,
population int,
New_Vaccinations int,
RollingTotalVaccinations int,
) 

INSERT INTO #PercentPopulationVaccinated 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(vacs.new_vaccinations) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingTotalVaccinations
FROM covid..CovidDeaths deaths
JOIN covid..CovidVaccinations vacs
    ON deaths.location = vacs.Location
    AND deaths.date = vacs.date 
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingTotalVaccinations/Population)*100
From #PercentPopulationVaccinated 

-- VIEWS FOR LATER VISUALIZATIONS 


-- percent vaccinated

CREATE VIEW populationvaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(vacs.new_vaccinations) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingTotalVaccinations
FROM covid..CovidDeaths deaths
JOIN covid..CovidVaccinations vacs
    ON deaths.location = vacs.Location
    AND deaths.date = vacs.date 
WHERE deaths.continent IS NOT NULL

