/*

Queries used for Tableau Project 

*/

--1.

Select SUM(new_cases) AS TotalCases,SUM(cast(new_deaths AS int)) AS TotalDeaths, sum(cast(new_deaths as int))/sum(New_cases)*100 AS DeathPercentage
FROM ProtfolioProject..CovidDeath
WHERE continent is not null
ORDER by 1,2




--2.

-- we take thes out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location,SUM(cast(new_deaths AS int)) AS TotalDeathsCount
FROM ProtfolioProject..CovidDeath
Where continent is null 
and location not in ('World','European Union','International')
Group by location
Order by TotalDeathsCount desc

--3.

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM ProtfolioProject..CovidDeath
Group by location,population
Order by PercentPopulationInfected desc

--4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProtfolioProject..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc