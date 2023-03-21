select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select the data that we going to use

select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--looking at the total cases vs total deaths
--death percentage in India

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where location = 'india' and continent is not null
order by 1,2

--looking at total cases vs population in india

select location, date, total_cases,population,(total_cases/population)*100 as casesPerPopulation
from PortfolioProject..CovidDeaths
where location = 'india' and  continent is not null
order by 1,2


--looking at countries with highest infection rate compared to population

select location,population,max( total_cases) as HigestInfeactionCount ,max((total_cases/population))*100 as casesPerPopulation
from PortfolioProject..CovidDeaths
--where location = 'india'
where continent is not null
group by population, location
order by casesPerPopulation desc


--showing countries with Highest death count per population

select location,max(cast(total_deaths as int)) as Totaldeaths
from PortfolioProject..CovidDeaths
--where location = 'india'
where continent is not null
group by  location
order by Totaldeaths desc


--lets break things down by continent
--showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as Totaldeaths
from PortfolioProject..CovidDeaths
--where location = 'india'
where continent is not null
group by  continent
order by Totaldeaths desc


--global numbers

select  date, sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
--where location = 'india' 
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
--where location = 'india' 
where continent is not null
--group by date
order by 1,2


--looking at total population vs vacinations

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as calculationofvacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- use cte

with PopvsVac (continent, location, date,population,new_vaccinations ,calculationofvacination)
as 
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as calculationofvacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (calculationofvacination/population)*100
from PopvsVac




--temp table
drop table if exists #PercentagePopulationVacinated
create table #PercentagePopulationVacinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
calculationofvacination numeric
)
insert into #PercentagePopulationVacinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as calculationofvacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (calculationofvacination/population)*100
from #PercentagePopulationVacinated



--creating view to store data for later visualization

create view PercentagePopulationVacinated as 
 select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as calculationofvacination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentagePopulationVacinated