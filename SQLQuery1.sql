Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Update CovidDeaths
Set total_deaths =NULL
Where total_deaths Is NULL Or total_deaths ='';

Update CovidDeaths
Set continent =NULL
Where continent Is NULL Or continent ='';

-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in your country (Here is Germany)
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%germany%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date,population, total_cases, 
(CONVERT(float, total_cases) / CONVERT(float, population)) * 100 AS Casespercentage
from PortfolioProject..CovidDeaths
where location like '%germany%'
order by 1,2

-- Looking at Countries with highest Infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, 
Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%germany%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc
								
-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continent with the highest death count per population

Select continent, max(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select Sum(cast(new_cases as int)) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

Update CovidVaccinations
Set new_vaccinations =NULL
Where new_vaccinations Is NULL Or new_vaccinations ='';

Select *
From PortfolioProject..CovidVaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
From PopvsVac




-- Temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
Select*, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
From #PercentPopulationVaccinated


-- creating view to store data for later visualization
create view percentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From percentPopulationvaccinated