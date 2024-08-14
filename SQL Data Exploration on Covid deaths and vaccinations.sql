select * 
From Portfolio_Project..CovidDeaths$
Where continent is not null
order by 3,4

--select * 
--From Portfolio_Project..CovidVaccinations$
--order by 3,4

-- select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population 
From Portfolio_Project..CovidDeaths$
Order by 1,2

-- loking at Total Cases Vs Total Deaths
-- Showes Likelihood of dying if you contract covid in your country 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
where location like'%India%'
Order by 1,2


-- Looking at Total Cases Vs Population 
-- Shows what percentage of population got covid

select Location, date, population, total_cases, (total_deaths/population)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
--where location like'%India%'
Order by 1,2


--Looking at What Countries with HighestInfection Rate compared to Popukation

select Location, population,MAX( total_cases ) as HighestInfectionCount
, MAX((total_deaths/population))*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths$
--where location like'%India%'
Group by Location, Population
Order by PercentPopulationInfected desc




--Showing Contrues With Highest Death Count Per Popuation 

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths$
--where location like'%India%'
Where continent is not null
Group by Location, Population
Order by TotalDeathCount desc


--Let's Break Things Down By Continent

-- Showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths$
--where location like'%India%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global Numbers 

select Sum(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  
SUM(cast(new_deaths as int))/SUM(New_cases) as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths$
--where location like'%India%'
where continent is not null
--Group by date
Order by 1,2

-- Looking at Total Populaion vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUm(cast(vac.new_vaccinations as int)) 
OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea 
join Portfolio_Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--Use CTE

WITH PopvsVac (continent,location, Date, Population, Nwe_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUm(cast(vac.new_vaccinations as int)) 
OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea 
join Portfolio_Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac





--Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUm(cast(vac.new_vaccinations as int)) 
OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea 
join Portfolio_Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later Visualization

Create View PercentPopulatenVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUm(cast(vac.new_vaccinations as int)) 
OVER(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths$ dea 
join Portfolio_Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3



select *
From PercentPopulatenVaccinated