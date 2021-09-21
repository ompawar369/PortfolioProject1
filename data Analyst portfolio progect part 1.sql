Select Location,max( cast(total_deaths as int) ) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc



--Let's Break things down by continent 
--Showing contintents with the highest daeaht ocunt per population
Select location,max( cast(total_deaths as int) ) as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--Golbal Numbers of deaths count


Select  SUM(new_cases) as Total_cases,sum(cast(new_deaths as int)) as total_deaths, sum( cast(new_deaths as int) )/ Sum (new_cases)*100 as TotalDeathCount
from portfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

-- join the 2 table 

Select * 
from portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
ON dea.location=vac.location
and dea.date = vac.date

-- looking at Total population vs Vacination 

Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.Date) as dumsos
from portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--USE CTE
-- with population vs vaccination


with PopvsVas (continent, location , date, population, new_vaccinations, rollingpeople) 
as
(
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.Date) as rollingpeople
from portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select * , (rollingpeople/population )*100 as populationname
from PopvsVas
--where location = 'India'



--Temp table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
New_vaccinations numeric,
Rolling numeric,
)
insert into #PercentPopulationVaccinated
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.Date) as Rolling
from portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * , (rolling/population )*100
from #PercentPopulationVaccinated


--creating view to store data for later visulatizations 
create view PercentPopulation as 
Select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.Date) as Rolling
from portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
	ON dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3