SELECT * FROM portfolio..CovidDeaths
order by 3,4
--SELECT * FROM portfolio..CovidVaccinations
--order by 3,4

--SELECT THE DATA WE WILL BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths
order by 1,2

--DEATH RATE(TOTAL DEATHS VS TOTAL CASES)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM portfolio..CovidDeaths
WHERE location like '%India%'
order by 1,2

--COVID RATE(TOTAL CASES VS POPULATION)

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidRate
FROM portfolio..CovidDeaths
--WHERE location like '%India%'
order by 1,2

--COUNTRIES WITH HIGHEST COVID RATE

SELECT location, MAX(total_cases) AS HighestCases, population, MAX((total_cases/population))*100 as CovidRate
FROM portfolio..CovidDeaths
GROUP BY location, population
order by CovidRate DESC

--COUNTRIES WITH HIGHEST DEATH RATE

SELECT location, population, MAX(Cast(total_deaths as int)) AS DeathCount, MAX((Cast(total_deaths as int)/population))*100 as DeathPercentage
FROM portfolio..CovidDeaths
where continent is not NULL
GROUP BY location, population
order by DeathCount DESC

--BREAKING THINGS BY CONTINENT 

SELECT location, MAX(Cast(total_deaths as int)) AS DeathCount, MAX((total_deaths/population))*100 as DeathPercentage
FROM portfolio..CovidDeaths
where continent is NULL
GROUP BY location
order by DeathCount DESC

-- GLOBAL STATISTICS 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathRate
FROM portfolio..CovidDeaths
--WHERE location like '%India%'
where continent is not null
--group by date
order by 1,2

-- TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by vac.location order by dea.location, dea.date) AS VacccinatedPeopleCountry
FROM portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


--USE CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, VacccinatedPeopleCountry)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by vac.location order by dea.location, dea.date) AS VacccinatedPeopleCountry
FROM portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
SELECT *, (VacccinatedPeopleCountry/population)*100
FROM PopvsVac


--TEMP TABLE


DROP table if exists #PercentPopulatedVaccinated
CREATE table #PercentPopulatedVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VacccinatedPeopleCountry numeric
)

INSERT into #PercentPopulatedVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by vac.location order by dea.location, dea.date) AS VacccinatedPeopleCountry
FROM portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3

SELECT *, (VacccinatedPeopleCountry/population)*100
FROM #PercentPopulatedVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by vac.location order by dea.location, dea.date) AS VacccinatedPeopleCountry
FROM portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated