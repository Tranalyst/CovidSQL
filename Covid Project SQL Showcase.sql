SELECT *
	FROM PortfolioProject..CovidDeaths
		WHERE continent is not null
			ORDER by 3,4


--SELECT *
--	FROM PortfolioProject..CovidVaccinations
--	order by 3,4

--Part 1 - Selecting dat that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
		ORDER BY 1,2



-- Total Cases vs Total Deaths (your state) USA
--Covid contraction in country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
		WHERE location like '%states%'
		and WHERE continent is not null
				ORDER by 1,2


--Total cases vs Population //Shows what % of population contracted Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
	FROM PortfolioProject..CovidDeaths
		WHERE location like '%states%'
			ORDER BY 1,2

-- Countries with Highest Infection Rate vs Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentagePopulationInfected
	FROM PortfolioProject..CovidDeaths
		--WHERE location like '%states%'
		GROUP BY Location, Population
		ORDER BY PercentagePopulationInfected DESC

--Countries with highest death per population.
--Found out that total_deaths is used as nvarchar, therefore need to cast as int to see accurate numbers
SELECT Location, MAX(cast(Total_deaths as int)) As TotalDeathCount
	FROM PortfolioProject..CovidDeaths
		--WHERE location like '%states%'
		WHERE continent is not null
			GROUP BY Location, Population
			ORDER BY TotalDeathCount DESC


-- Continents with highest death counts per population
SELECT continent, MAX(cast(Total_deaths as int)) As TotalDeathCount
	FROM PortfolioProject..CovidDeaths
		WHERE continent is not null
			GROUP BY continent
			ORDER BY TotalDeathCount DESC


-- Starting Aggregate Function sessions

--Global Numbers death percentages
SELECT SUM(new_cases) AS new_cases, SUM(cast(new_deaths as int)) AS new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
		WHERE continent is not null
			--GROUP BY date
			ORDER by 1,2



-- total population vs vaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
		, SUM(cast(vaccine.new_vaccinations as int)) OVER (PARTITION BY death.location, death.date) AS RollCountVaccinated
		, --(RollCountVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths AS death --Alias 
	Join PortfolioProject..CovidVaccinations AS vaccine -- Alias
		On death.location = vaccine.location
			and  death.date = vaccine.date
			WHERE death.continent is not null
			ORDER BY 2,3


--Start CTE for variable RollCountVaccinated
--Name of Temp Table is PvsV for People Vs Vaccination --Adding columns in equal numbers of the Select Statement.
With PvsV (Continent, Location, Date, Population, New_Vaccinations, RollCountVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
		, SUM(cast(vaccine.new_vaccinations as int)) OVER (PARTITION BY death.location, death.date) AS RollCountVaccinated
		 --,(RollCountVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths AS death --Alias 
	Join PortfolioProject..CovidVaccinations AS vaccine -- Alias
		On death.location = vaccine.location
			and  death.date = vaccine.date
			WHERE death.continent is not null
)
Select *, (RollCountVaccinated/Population)*100
FROM PvsV
--WHERE RollCountVaccinated is not null;


--Creating a permenant table as an alternative solution

DROP TABLE if exists PopVacPercentage
CREATE TABLE PopVacPercentage
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	population numeric,
	New_vaccinations numeric,
	RollCountVaccinated numeric
)


INSERT INTO PopVacPercentage
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
		, SUM(cast(vaccine.new_vaccinations as int)) OVER (PARTITION BY death.location, death.date) AS RollCountVaccinated
		 --,(RollCountVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths AS death --Alias 
	Join PortfolioProject..CovidVaccinations AS vaccine -- Alias
		On death.location = vaccine.location
			and  death.date = vaccine.date
			WHERE death.continent is not null

Select *, (RollCountVaccinated/Population)*100
FROM PopVacPercentage
			

CREATE VIEW PPopVacPercentage as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
		, SUM(cast(vaccine.new_vaccinations as int)) OVER (PARTITION BY death.location, death.date) AS RollCountVaccinated
		 --,(RollCountVaccinated/population)*100
	FROM PortfolioProject..CovidDeaths AS death --Alias 
	Join PortfolioProject..CovidVaccinations AS vaccine -- Alias
		On death.location = vaccine.location
			and  death.date = vaccine.date
			WHERE death.continent is not null



SELECT * 
	FROM PPopVacPercentage
	