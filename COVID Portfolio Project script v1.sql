 ---Over all Data we have
SELECT * FROM CovidDeaths
ORDER BY 3,4

SELECT * FROM CovidVaccination
ORDER BY 3,4

-- Data we are going to use--
SELECT continent, location, date, population, total_cases,new_cases,total_deaths FROM CovidDeaths ORDER BY 2,3

SELECT COUNT(continent) FROM CovidDeaths 

SELECT continent FROM CovidDeaths 
GROUP BY continent

---Looking at Total cases vs Total Deaths
SELECT location,date,total_cases,total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location='India' and total_cases > 0 and total_deaths>0
order by 1,2

---Finding  Max total cases from India 
SELECT location,date,total_cases,total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location='India' and total_cases > 0
order by 2

SELECT location,date,total_cases,total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location='India' AND total_cases=(SELECT MAX(total_cases)  as Max_total_cases from CovidDeaths WHERE location='India')
order by 1,2


---Finding Max total cases in all over world
SELECT location,date,total_cases,total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as DeathPercentage
FROM CovidDeaths 
WHERE total_cases=(SELECT MAX(total_cases) FROM CovidDeaths)

---finding Min total cases in all over world greather than zero
SELECT location,date,total_cases,total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as DeathPercentage
FROM CovidDeaths 
WHERE total_cases=(SELECT MIN(total_cases) FROM CovidDeaths WHERE total_cases >0) 
ORDER BY 1,2

---Total cases vs population and find the percentage of population that effected by covid
SELECT location,date, total_cases,population, (total_cases/population) * 100 AS CovidAffectedPercentage
FROM CovidDeaths where location='India' 
order by 1,2

--Max Indian people affected by Covid
SELECT location,date, total_cases,population, (total_cases/population) * 100 AS CovidAffectedPercentage
FROM CovidDeaths where location='India' AND total_cases=(SELECT MAX(total_cases) as HighestEffected from CovidDeaths where location='India')
order by 1,2
----Min Indian people affected by covid
SELECT location,date, total_cases,population, (total_cases/population) * 100 AS CovidAffectedPercentage
FROM CovidDeaths where location='India' AND 
total_cases=(SELECT MIN(total_cases) as HighestEffected from CovidDeaths where location='India' AND total_cases !=0)
order by 1,2


----GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null

                                  -------Working on Another Table called Covid Vaccinations-----


Select * from CovidVaccination where total_tests is not null order by 5 desc

--Looking at Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population, dea.total_cases,vac.total_vaccinations ,vac.new_vaccinations
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where total_vaccinations is not null
and dea.continent='Asia'
order by 2,3


Select dea.continent,dea.location,dea.date,dea.population, dea.total_cases ,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where total_vaccinations is not null
and dea.continent='Asia'
order by 2,3
 

 ---USING CTE
 With PopVsVac(Continent,Location,Dare,Population,Total_cases,New_Vaccinations,RollingPeopleVaccinated)
 as
 (Select dea.continent,dea.location,dea.date,dea.population, dea.total_cases ,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100 from PopVsVac


----TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DateTime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

SELECT * ,(RollingPeopleVaccinated/Population) * 100 FROM  #PercentPopulationVaccinated


-----VIEW------
CREATE VIEW [Asia Vaccines] AS
SELECT continent, date, total_tests,total_vaccinations
FROM CovidVaccination
WHERE continent='Asia'

SELECT TOP 1000 * FROM [Asia Vaccines] WHERE total_vaccinations IS NOT NULL  




