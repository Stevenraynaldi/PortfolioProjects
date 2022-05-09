Select * From PortfolioProject..CovidDeath
order by 3,4


-- Select * From CovidVaccination
-- order by 3,4

-- Select data that we are using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
Order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if you contract  covid in Singapore
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeath
Where continent is not null
And location = 'Singapore'
Order by 1,2


-- Look at total cases vs population
-- Shows what population got covid
Select location, date, total_cases,population, (total_cases / population)*100 as InfectedRate
from PortfolioProject..CovidDeath
Where continent is not null
And location = 'Singapore'
Order by 1,2


-- What country has the highest infectionRate
Select location, population, Max(total_cases) as HighestInfectionCount, max(total_cases / population)*100 as InfectedRate, max(total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
Group By location, population
Order by InfectedRate desc


-- Showing countries witht he highest death count per population
-- First problem encountered is data type of total_deaths
-- There are aggregated number in the data set
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is not null
-- And location = 'Singapore'
Group By location
Order by TotalDeathCount desc


-- Let's break it down by continent

-- -- Showing continents with the highest death counts per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is not null 
-- And location = 'Singapore'
Group By continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, Sum(new_cases) as GlobalNewCase, sum(cast(new_deaths as int)) as GlobalNewDeath, Sum(cast(new_deaths as int))/ Sum(New_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeath
Where continent is not null
-- And location = 'Singapore'
Group by date 
Order by 1,2


Select * From PortfolioProject ..CovidVaccination


-- Looking at Total Population vs vaccination
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_vaccinated
From PortfolioProject..CovidDeath as cd
Join PortfolioProject ..CovidVaccination as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
and cd.location = 'Singapore'
order by 1,2,3


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, Total_Rolling_vaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_vaccinated
From PortfolioProject..CovidDeath as cd
Join PortfolioProject ..CovidVaccination as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
and cd.location = 'Singapore'
)
Select *, (Total_Rolling_vaccinated/population)*100 as Rolling_Vaccinated_Percentage
From PopvsVac


-- USE CTE (Self practice)
-- Showing death percentage per day vs number of vaccination
with DeavsVac (Continent, Location, Date, Population, New_vaccinations, Total_Rolling_vaccinated, New_deaths, Total_Rolling_Deaths)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_vaccinated
, cd.new_deaths, sum(convert(int, cd.new_deaths)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_Deaths
From PortfolioProject..CovidDeath as cd
Join PortfolioProject ..CovidVaccination as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
and cd.location = 'Singapore'
)
Select Continent, location, date, (Total_Rolling_vaccinated/population)*100 as Rolling_Vaccinated_Percentage, (Total_Rolling_Deaths/population)*100 as Rolling_Deaths_Percentage
From DeavsVac


-- Temp Table

Drop table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Rolling_vaccinated numeric
)

Insert into #PercentpopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_vaccinated
From PortfolioProject..CovidDeath as cd
Join PortfolioProject ..CovidVaccination as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
and cd.location = 'Singapore'
Select *, (Total_Rolling_vaccinated/population)*100 as Rolling_Vaccinated_Percentage
From #PercentpopulationVaccinated


-- Creating views to store data for visualisations

Create View PercentpopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as Total_Rolling_vaccinated
From PortfolioProject..CovidDeath as cd
Join PortfolioProject ..CovidVaccination as cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null

select* from PercentpopulationVaccinated