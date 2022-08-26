select top 10 *
from dbo.CovidDeaths;

select top 10 *
from dbo.CovidVaccinations;

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by location, date 

-- Total cases vs Total Deaths for each country
--shows the likelihood of dying if contract Covid-19 in your country
Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as death_percentage
from dbo.CovidDeaths
where location like '%states%' --to get United States data
order by location, date


-- Looking at the total cases vs the population
--shows what percentage of population got Covid-19 In India and United States
Select location, date, population, total_cases, total_deaths, round((total_cases/population)*100, 2) as infection_rate
from dbo.CovidDeaths
where location IN ('India', 'United States') 
order by location, date 

-- which country has highest infection and death rate

SELECT  TOP 1 location, population, total_cases, round((total_cases/population)*100, 2) as infection_rate
from dbo.CovidDeaths
where continent is not  null
order by infection_rate desc

--Countries with Highest Infection rate compared to Population
SELECT location, population, max(total_cases) as HighestInfectionCount, max(round((total_cases/population)*100, 2)) as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not  null
Group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death rate compared to Population
SELECT location, population, max(cast(total_deaths as int)) as HighestInfectionCount, max(round((total_deaths/population)*100, 2)) as PercentDeaths
from dbo.CovidDeaths
where continent is not  null
Group by location, population
order by PercentDeaths desc, population desc

--Breaking things out by continent
--Continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select date, sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking for total population vs Vaccinations
with cte1
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, round((RollingPeopleVaccinated/Population)*100, 2) as PercentPopulationVaccinated
from cte1

--creating View to store date for vi
Create View PercentPopulationVaccinated as

with cte1
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, round((RollingPeopleVaccinated/Population)*100, 2) as PercentPopulationVaccinated
from cte1






--Find when was the first death recorded for each country
select location, date as first_death_recorded_date
from (
Select location, date, row_number() over(partition by location order by total_deaths) as rn
from dbo.CovidDeaths
where total_deaths is not null and  continent is  not null) result
where rn = 1
