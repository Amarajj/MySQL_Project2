SELECT * 
FROM Porfolio_project.coviddeaths
WHERE continent is not null
order by 3,4;

-- SELECT * 
-- FROM Porfolio_project.covidvaccination
-- order by 3,4;


-- select data I am 

SELECT location, date, total_cases,  new_cases, total_deaths, population
FROM Porfolio_project.coviddeaths
WHERE continent is not null
order by 1,2;


-- looking at Total cases Vs Toltal deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
FROM Porfolio_project.coviddeaths
where location like '%Africa%'
order by 1,2;
-- Shows the likely hood of dieing if you contact HIV
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
FROM Porfolio_project.coviddeaths
where location like '%NIGERIA%'
order by 1,2;


-- looking at total cases vs population
-- Show percentage of the population got covid
SELECT location, date, population,total_cases,  (total_deaths/population)* 100 as PercentPopulationInfected
FROM Porfolio_project.coviddeaths
where location like '%NIGERIA%'
order by 1,2;

-- looking at countries with highest infection rate compare to infection

SELECT location, population, MAX(total_deaths) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
Group by location, population
order by PercentPopulationInfected desc;

-- Showing the countries with the higherst death count per population

SELECT Location, 
	MAX(total_deaths) as TotalDeathCount
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
WHERE continent is null
Group by location
order by TotalDeathCount desc;


-- Let break things by continent

SELECT continent,	
	MAX(total_deaths) as TotalDeathCount
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc;


-- Showing the continent with the highest death count per population

SELECT continent,	
	MAX(total_deaths) as TotalDeathCount
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc;


--  Global numbers

SELECT date, SUM(new_cases) , SUM(new_deaths)as DeathPecentage
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
WHERE continent is not null
Group by date
order by 1,2;


SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths/new_cases)* 100 as DeathPecentage
FROM Porfolio_project.coviddeaths
-- where location like '%NIGERIA%'
WHERE continent is not null
Group by date
order by 1,2;

-- joining two tables together on location and date
-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Porfolio_project.coviddeaths dea
Join Porfolio_project.covidvaccination vac
	On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
    order by 2,3;
    
-- error    
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations), 
    OVER(partition by dea.location)
FROM Porfolio_project.coviddeaths dea
Join Porfolio_project.covidvaccination vac
	On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
    order by 2,3;
    
    

-- 
-- Use CTE
WITH Popvsvac (continent, location, date, population, NewVaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        Porfolio_project.coviddeaths dea
    JOIN 
        Porfolio_project.covidvaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *, 
    RollingPeopleVaccinated
FROM 
    Popvsvac;
    
    
    -- temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255)
Location Nvarchar(255)
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        Porfolio_project.coviddeaths dea
    JOIN 
        Porfolio_project.covidvaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
   -- WHERE 
       -- dea.continent IS NOT NULL
)
SELECT 
    *, 
    RollingPeopleVaccinated
FROM 
    PercentPopulationVaccinated;
    
--
-- Drop the temporary table if it exists
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population DECIMAL,
    new_vaccination DECIMAL,
    RollingPeopleVaccinated DECIMAL
);

-- Insert data into the temporary table
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    Porfolio_project.coviddeaths dea
JOIN 
    Porfolio_project.covidvaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- Query data from the temporary table
SELECT 
    *, 
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM 
    PercentPopulationVaccinated;
    
    
    
    -- Create view to store for later visualiztion
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Porfolio_project.coviddeaths dea
Join Porfolio_project.covidvaccination vac
	On dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
   -- order by 2,3;