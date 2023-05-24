select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..['Covid death$']
order by 1,2

-- Total Cases VS Total Deaths in India
select 
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as Deathpercentage
from [Portfolio Project]..['Covid death$']
where location ='India'
order by 1,2

-- Total Cases VS Population In India
-- What % of population got Covid. 
select 
location,
date,
total_cases,
population,
(total_cases/population)*100 as Casespercentage
from [Portfolio Project]..['Covid death$']
where location ='India'
order by 1,2

-- Countries withHighest Infection rate as compared to population
select 
location,
max(total_cases) as highestinfectioncount,
population,
max((total_cases/population))*100 as percentpopulationinfected
from [Portfolio Project]..['Covid death$']
group by location,population
order by percentpopulationinfected desc


-- Countries with the highest death count per population
select 
location,
max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid death$']
where continent is not null
group by location
order by totaldeathcount desc

-- Continents with the highest death count per population
select 
continent,
max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..['Covid death$']
where continent is not null
group by continent
order by totaldeathcount desc

-- New cases and deaths across the world

select 
date,
sum(new_cases) as newcases,
sum(CAST(new_deaths as int)) as newdeaths,
sum(CAST(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from [Portfolio Project]..['Covid death$']
where continent is not null
group by date
--where location ='India'
order by 1,2

-- Joining two tables

Select * 
from [Portfolio Project]..['Covid death$'] as Dea
Join [Portfolio Project]..['Covid vaccination$'] as vac
on dea.location = vac.location
and dea.date = vac.date

--How many people in world gotvaccinated?
Select 
dea.continent,
dea.location,
dea.date,
vac.new_vaccinations
from [Portfolio Project]..['Covid death$'] as Dea
Join [Portfolio Project]..['Covid vaccination$'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Rolling count of vaccinations across different locations
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['Covid death$'] as Dea
Join [Portfolio Project]..['Covid vaccination$'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE 
with PopVsVac (continent, location,date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..['Covid death$'] as Dea
Join [Portfolio Project]..['Covid vaccination$'] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopVsVac
