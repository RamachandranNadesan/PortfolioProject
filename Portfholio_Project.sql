--Data
Select * From CovidDeaths
Where continent is Not Null

--Shows likelihood of dying if you contract covid in India
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like'%India%' and continent is Not Null
Order by 1,2

--Lookin at Toatal Cases vs Population
--Shows what percentage of population got Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected	
From CovidDeaths
--Where location like'%India%'
Where continent is Not Null
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases) as HighestInfection,Max((total_cases/population)*100) as PercentPopulationInfected	
From CovidDeaths
--Where location like'%India%'
Where continent is Not Null
Group by location,population
Order by 4 desc

--Showing Countries with Highest Death Count per Poulation

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount	
From CovidDeaths
--Where location like'%India%'
Where continent is Not Null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with Highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount	
From CovidDeaths
--Where location like'%India%'
Where continent is Not Null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like'%India%'  
Where continent is Not Null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
from CovidDeaths dea
Join CovidVaccinations vac on
dea.location=vac.location and dea.date=vac.date
Where dea.continent is Not Null
Order by 2,3


--CTE

With PopvsVac(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac on
dea.location=vac.location and dea.date=vac.date
Where dea.continent is Not Null
)

Select *,(RollingPeopleVaccinated/Population)*100
From 
PopvsVac


--TEMP TABLE	
Drop table if exists #PercentPoulationVaccinated 
Create Table #PercentPoulationVaccinated
(
Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,New_Vaccinations numeric,RollingPeopleVaccinated numeric)

Insert into #PercentPoulationVaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac on
dea.location=vac.location and dea.date=vac.date
--Where dea.continent is Not Null

Select *,(RollingPeopleVaccinated/Population)*100
From 
#PercentPoulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPoulationVaccinated as 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac on
dea.location=vac.location and dea.date=vac.date
Where dea.continent is Not Null
--Order by 2,3

Select * from PercentPoulationVaccinated