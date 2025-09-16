select * from dbo.CovidDeaths$ 
where continent is not null
order by 3,4

--select * from dbo.['Covid vaccination$']
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths$
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in nigeria

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where location like '%nigeria%'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths$
--where location like '%nigeria%'
order by 1,2


--Looking at Countries with Highest Infection Rate comapred to Population


select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths$
--where location like '%nigeria%'
group by location, population
order by PercentPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continuents with the highest death count per population


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2




-- Looking at Total Population vs Vaccinations


WITH  PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.['Covid vaccination$'] vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
--USE CTE



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vacciantions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.['Covid vaccination$'] vac
	on dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data data for later visualization

Create View PercentPopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from dbo.CovidDeaths$ dea
join dbo.['Covid vaccination$'] vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3


select * 

from PercentPopulationVaccinated
