Select * 
From PortfolioProject.dbo.['CovidDeaths']
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.['CovidDeaths']
Order by 1,2

-- Total Cases vs Total Deaths
-- What percentage of those who contracted Covid died

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject.dbo.['CovidDeaths']
Where location like 'india'
Order by 1,2

-- Total Cases vs Population
-- What percentage of the population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as SickPercent
From PortfolioProject.dbo.['CovidDeaths']
--Where location like 'india'
Order by 1,2 

-- Countries with Highest Infection Rate per Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPercent
From PortfolioProject.dbo.['CovidDeaths']
-- Where location like 'ireland'
Group by location, population
Order by InfectedPercent desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.['CovidDeaths']
-- Where location like 'ireland'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Most Deaths By Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.['CovidDeaths']
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers per day

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercent
From PortfolioProject.dbo.['CovidDeaths']
Where continent is not null
Group By date
Order by 1,2

-- Total Global Numbers (deaths v cases)

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercent
From PortfolioProject.dbo.['CovidDeaths']
Where continent is not null
--Group By date
Order by 1,2

-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaxxed
--,(RollingPeopleVaxxed/population)*100
From PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--Using CTE  for usage of RollingPeopleVaxxed

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaxxed)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaxxed
--,(RollingPeopleVaxxed/population)*100
From PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaxxed/Population)*100
FROM PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaxxed numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaxxed
--,(RollingPeopleVaxxed/population)*100
From PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaxxed/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaxxed
--,(RollingPeopleVaxxed/population)*100
From PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated