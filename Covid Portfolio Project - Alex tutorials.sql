
SELECT *
FROM Portfolio_project..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM Portfolio_project..CovidVaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM Portfolio_project..CovidDeaths
where continent is not null
order by 1, 2


-- Total Cases vs Total Deaths (percentage of deaths)
SELECT location, date, total_cases, total_deaths, new_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE location like '%states%'
order by 1, 2


-- total cases vs population (percentage of population that got covid)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PctPopulationaffected
FROM Portfolio_project..CovidDeaths
WHERE location like '%states%'
order by 1, 2


-- countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases),MAX((total_cases/population))*100 AS Highest_Infection_cnt
FROM Portfolio_project..CovidDeaths
group by location, population
order by Highest_Infection_cnt desc


-- countries with highest death rates per population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- continents with highest death rates per population by continent
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- continents with the highest death count
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- global numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null 
--Group by date
order by 1, 2


--CTE 
WITH PopsvsVacc (continent, location, date, population, new_vaccinations, rolling_vac)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) over (partition by deaths.location Order by deaths.location, deaths.date) as rolling_vacc
--(rolling_vac/population)*100
FROM Portfolio_project..CovidDeaths as deaths
JOIN Portfolio_project..CovidVaccination as vacc
ON 
deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null
--order by 2,	3
)

Select *, (rolling_vac/population)*100
From PopsvsVacc


--temp table
Drop table if exists #pctpopvacc 
Create Table #pctpopvacc 
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vac numeric
)

INSERT INTO #pctpopvacc 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) over (partition by deaths.location Order by deaths.location, deaths.date) as rolling_vacc
--(rolling_vac/population)*100
FROM Portfolio_project..CovidDeaths as deaths
JOIN Portfolio_project..CovidVaccination as vacc
ON 
deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null
--order by 2,3

Select *, (rolling_vac/population)*100
FROM #pctpopvacc 


-- creating views to store data later tableau viz

Create View percentage as 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) over (partition by deaths.location Order by deaths.location, deaths.date) as rolling_vacc
--(rolling_vac/population)*100
FROM Portfolio_project..CovidDeaths as deaths
JOIN Portfolio_project..CovidVaccination as vacc
ON 
deaths.location = vacc.location
and deaths.date = vacc.date
where deaths.continent is not null
--order by 2,3

Select *
FROM percentage
