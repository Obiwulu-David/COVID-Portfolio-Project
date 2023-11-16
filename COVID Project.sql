select *
from projectporfolio..CovidDeaths
order by 1,2,3

select *
from projectporfolio..CovidVaccinations
order by 1,2,3

select location, date, total_cases, new_cases, total_deaths, population
from projectporfolio..CovidDeaths
order by 1,2,3

--total (cases vs deaths) with focus in Nigeria/ Africa
select location,continent, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as deathpercentage
from projectporfolio..CovidDeaths
where location like '%nigeria%'
order by 1,2

--total cases vs population(% of infected people)
select location, date, population, total_cases, 
(population/total_cases)*100 as infectedpercentage
from projectporfolio..CovidDeaths
where location like '%south africa%'
order by 1,2

--countries with highest infection rate /population
select location, population, max(total_cases) as highestinfestion, 
max((population/total_cases))*100 as maxinfectedpopulation
from projectporfolio..CovidDeaths
--where location like '%south africa%'
group by location, population
order by maxinfectedpopulation desc

--countries with highest death count/ population
select location, population, max(cast(total_deaths as int)) as deathcount
from projectporfolio..CovidDeaths
where continent is null
group by location, population
order by deathcount desc

--continent with the highest death rate
select population, continent, max(total_deaths) as deathcount
from projectporfolio..CovidDeaths
where continent is null
group by population, continent
order by deathcount desc

--global numbers
select date, sum(new_cases) total_new_cases, 
sum(cast(new_deaths as int)) total_new_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 deathpercentage
from projectporfolio..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) total_new_cases, 
sum(cast(new_deaths as int)) total_new_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)*100 deathpercentage
from projectporfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2

--total population vs vacination
select cod.location, cod.date, cov.continent, 
cod.population, cov.new_vaccinations
from projectporfolio..CovidDeaths cod
join projectporfolio..CovidVaccinations cov
on cod.location = cov.location
and cod.date = cov.date
where cov.continent is not null
order by 1,2,3

--rolling count of new_vacination
select cod.location, cod.date, cov.continent, 
cod.population, cod.new_vaccinations, 
sum(convert(int, cod.new_vaccinations))
over (partition by cod.location order by cod.location, cod.date)
as rollingcountvaccinated
from projectporfolio..CovidDeaths cod
join projectporfolio..CovidVaccinations cov
on cod.location = cov.location
and cod.date = cov.date
where cov.continent is not null
order by 1,2,3

--total_vaccination vs population

with popuvac (location, continent, date, 
population, new_vaccinations, rollingcountvaccinated)
as (
select cod.location, cod.date, cov.continent, 
cod.population, cod.new_vaccinations, 
sum(convert(int, cod.new_vaccinations))
over (partition by cod.location order by cod.location, cod.date)
as rollingcountvaccinated --(rollingcountvaccinated/population)*100
from projectporfolio..CovidDeaths cod
join projectporfolio..CovidVaccinations cov
on cod.location = cov.location and cod.date = cov.date
where cov.continent is not null)
select *, (rollingcountvaccinated/population)*100
from popuvac

--creating temp table
--drop table if exists #percentageofvaccinated
--create table #percentageofvaccinated
--(location nvarchar(500), date datetime, continent nvarchar,
--population numeric, new_vaccinations numeric, 
--rollingcountvaccinated numeric)

--insert into #percentageofvaccinated
--select cod.location, cod.date, cod.continent, 
--cod.population, cod.new_vaccinations, 
--sum(convert(int, cod.new_vaccinations))
--over (partition by cod.location order by cod.location, cod.date)
--as rollingcountvaccinated --(rollingcountvaccinated/population)*100
--from projectporfolio..CovidDeaths cod
--join projectporfolio..CovidVaccinations cov
--on cod.location = cov.location and cod.date = cov.date
----where cov.continent is not null)
----order by 1,2,3

--select *, (rollingcountvaccinated/population)*100
--from #percentageofvaccinated

--VIEWS FOR LATER IN VISUALIZATION
create view popuvac as
select cod.location, cod.date, cov.continent, 
cod.population, cod.new_vaccinations, 
sum(convert(int, cod.new_vaccinations))
over (partition by cod.location order by cod.location, cod.date)
as rollingcountvaccinated --(rollingcountvaccinated/population)*100
from projectporfolio..CovidDeaths cod
join projectporfolio..CovidVaccinations cov
on cod.location = cov.location and cod.date = cov.date
where cov.continent is not null
