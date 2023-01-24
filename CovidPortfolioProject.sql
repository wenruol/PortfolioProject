select * from ..CovidVacccination$
order by 3,4
	

select * from PortfolioProject..Coviddealth
where location like '%income%'
order by 3,4


--total cases vs total deaths
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddealth
order by 1,2

--shows likelihood of dying in different countries	

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage	
from PortfolioProject..Coviddealth
where location like '%states%'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage	
from PortfolioProject..Coviddealth
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, max(total_cases) as HighestInfectionCount, population, (MAX(total_cases)/population)*100 as PercentPopulationInfected	
from PortfolioProject..Coviddealth
Group by location,population
--where location like '%states%'
order by PercentPopulationInfected desc

--show countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount	
from PortfolioProject..Coviddealth
where continent is not Null 
Group by location
order by TotalDeathCount Desc

--breakdown by continent

--select location, max(cast(total_deaths as int)) as TotalDeathCount	
--from PortfolioProject..Coviddealth
--where continent is Null and location not like '%income%'
--Group by location
--order by TotalDeathCount Desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount	
from PortfolioProject..Coviddealth
where continent is not null	
Group by continent
order by TotalDeathCount Desc

--Global numbers

select date, SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_dealths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage	
from PortfolioProject..Coviddealth
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_dealths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage	
from PortfolioProject..Coviddealth
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2



Select * from PortfolioProject..CovidVacccination

Select * from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.location=vac.location and dea.date=vac.date
order by 3,4

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVacTotal
from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null
order by 2,3



--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations,RollingVacTotal)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVacTotal
from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVacTotal/population)*100
from PopvsVac


--temp table 
--Just put DROP TABLE IF EXISTS `tablename`; before your CREATE TABLE statement.That statement drops the table if it exists but will not throw an error if it does not.

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
New_vaccinations numeric,
RollingVacTotal numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVacTotal
from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null
--order by 2,3

Select *, (RollingVacTotal/Population)*100
from #PercentPopulationVaccinated


--create view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVacTotal
from PortfolioProject..Coviddealth dea Join PortfolioProject..CovidVacccination vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null

Select*
from PercentPopulationVaccinated