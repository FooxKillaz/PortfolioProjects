SELECT * FROM PortfolioProject..CovidDeaths$ 
WHERE continent is not null
ORDER BY 3,4
--BASE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null and location like '%Brazil%' 
ORDER BY location, date;

-- COMPARAÇÃO DE ALTA DE INFECÇÃO X POPULAÇÃO
SELECT location, date, total_cases, total_deaths, (total_cases/population)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--WHERE location like '%Brazil%' 
ORDER BY location, date;

-- CONTINENTES COM MAIORES MORTES POR POPULAÇÃO

SELECT Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
-- WHERE location like '%Brazil%' 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;

-- CORTE POR CONTINENTE

---CONTINENTES COM AS MAIORES TAXAS DE MORTE

SELECT continent, max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--WHERE location like '%Brazil%' 
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- NÚMEROS GLOBAIS

SELECT Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null 
--WHERE location like '%Brazil%' 
--GROUP BY date
HAVING sum(new_cases) <> 0
ORDER BY 1,2

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
--TOTAL MORTES DA POPULAÇÃO X VACINAÇÃO
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order By dea.location) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) *100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac
--CTE

--TEMP table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255),Date datetime, Population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order By dea.location) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population) *100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated


--VISUALIZAÇÃO DA TABELA
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location Order By dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * 
FROM PercentPopulationVaccinated
