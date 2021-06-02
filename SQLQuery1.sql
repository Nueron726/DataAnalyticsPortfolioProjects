--Select *
--from PortfolioProject..CovidDeath$
--order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using

Select location, date, new_cases, total_deaths, population
from PortfolioProject..CovidDeath$
order by 1, 2


--Looking at the Total cases vs Total deaths
--likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where location like '%states%'
order by 1 , 2

--looking at the total cases vs population
--percentage of population that got covid 
--Death percentage is then actually "PercentofPopulationInfected"

Select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeath$
--where location like '%states%'
order by 1 , 2

--Looking at countries with higest infection rates compared to populations
--sidenote: errorstacktricein MySql is intuitive!

Select location, population, MAX(total_cases) as HighestINfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeath$
--where location like '%states%'
Group by location, population
order by PercentofPopulationInfected desc 

--Showing countries with highest death count per populations

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeath$
--where location like '%states%'
Where continent is not null
Group by location, population
order by TotalDeathCount desc


--showing the continents with the higest death count per populations

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeath$
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercetnage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
--where location like '%states%'
where continent is not null
--Group by date
order by 1 , 2

--Looking at the total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3




--Use cte
--if the number of paramters are different from what you have in the method it will give you a syntax error
with PopvsVac (Continent, Location, Date, population, New_Vaccination, RollingPeopleVaccinated)
as

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
--	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
--	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

--we can no query off this new temp table we've created!

Select *
from PercentPopulationVaccinated

