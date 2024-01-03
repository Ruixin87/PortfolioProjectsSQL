Select * 
FROM ProtfolioProject..CovidDeath
Where continent is not null 
ORDER by 3,4

--Select * 
--FROM ProtfolioProject..CovidVaccinations
--ORDER by 3,4

-- Select Data that we are going to be using 

Select Location,date,total_cases,new_cases,total_deaths,population
FROM ProtfolioProject..CovidDeath
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in your country 
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM ProtfolioProject..CovidDeath
WHERE Location Like '%Australia%'
ORDER by 1,2

--Looking at Total Cases vs Population 
--Shows what percentage of population got covid

Select Location,date,Population,total_cases,(total_cases/population)*100 AS PercentPopulationCovidRate
FROM ProtfolioProject..CovidDeath
--WHERE Location Like '%Australia%'
ORDER by 1,2

-- Looking at Countries with Highest Infection rate compared to population 

Select Location,population,max(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationCovidRate
FROM ProtfolioProject..CovidDeath
GROUP BY location,population
ORDER by PercentPopulationCovidRate Desc

-- Showing Countries with Highest Death Count per Population 

Select Location,MAX(cast(Total_deaths as int))AS TotalDeathCount
FROM ProtfolioProject..CovidDeath
Where continent is not null 
GROUP BY location
ORDER by TotalDeathCount Desc

-- Let's Break things down by Continent

Select continent,MAX(cast(Total_deaths as int))AS TotalDeathCount
FROM ProtfolioProject..CovidDeath
Where continent is not null 
GROUP BY continent 
ORDER by TotalDeathCount Desc

-- The above table showing is not accturate so we do again to Showing Continent with the highest death count per population

Select location,MAX(cast(Total_deaths as int))AS TotalDeathCount
FROM ProtfolioProject..CovidDeath
Where continent is null 
GROUP BY location
ORDER by TotalDeathCount Desc

-- Global Numbers

Select date,SUM(new_cases) AS TotalCases,SUM(cast(new_deaths AS int)) AS TotalDeaths, sum(cast(new_deaths as int))/sum(New_cases)*100 AS DeathPercentage
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
Group by date
ORDER by 1,2

Select SUM(new_cases) AS TotalCases,SUM(cast(new_deaths AS int)) AS TotalDeaths, sum(cast(new_deaths as int))/sum(New_cases)*100 AS DeathPercentage
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
ORDER by 1,2



-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeath dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Use CTE to perform Calculation on Partition by in previous query

WITH PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dec.population)*100
FROM ProtfolioProject..CovidDeath dea
JOIN ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 as VaccinationRate
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dec.population)*100
FROM ProtfolioProject..CovidDeath dea
JOIN ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--Order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as VaccinationRate
From #PercentPopulationVaccinated


-- Createing View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dec.population)*100
FROM ProtfolioProject..CovidDeath dea
JOIN ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL 

Select *
FROM PercentPopulationVaccinated