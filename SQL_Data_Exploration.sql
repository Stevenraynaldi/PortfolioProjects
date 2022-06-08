-- Welcome to my covid 19 data exploration project using SQL
-- My idea of doing this is to understand the effects of Covid 19 on the world and also specifically Singapore. 
-- I will also be using different data exploration techniques to explore and transform the data in a way that will be useful for us.
-- TLDR:
	-- Part 1: The relationship between total case of Covid, deaths and infection rate due to covid from Singapore and around the world
		-- Here I focus on exploration of data using Group by, Order by and manipulation of columns using functions such as Max and Sum.
	-- Part 2: The relationship between covid and Vaccination
		-- Here I used Joins, CTE, creating views and temp table

--------------------------------------------------------------------The full data--------------------------------------------------------------------
Select * From PortfolioProject..CovidDeath
order by 3,4

Select * From CovidVaccination
order by 3,4


--------------------------------------------------------------------Part 1: Total covid case and death --------------------------------------------------------------------
-- Select data that we are using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
Order by 1,2

-- Quick look of Singapore cases on 7 May 2022
-- Total Covid case:			1,215,499
-- Number of Covid related Death:	1350


-- Looking at total cases vs total deaths
-- As of 7 May 2022, In Singapore, if you contract covid, there is a 0.11% chance of dying
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeath
Where continent is not null
And location = 'Singapore'
Order by 1,2


-- Look at total cases vs population
-- The infection rate Shows perfentage of population that got covid
-- As of 7 May 2022, Singapore have infection rate of 22.29% (1,215,499 positive cases)
Select location, date, total_cases,population, (total_cases / population)*100 as InfectedRate
from PortfolioProject..CovidDeath
Where continent is not null
And location = 'Singapore'
Order by 1,2


-- What country has the highest infectionRate
-- Faeroe Islands has the highest infection rate of 70.65%
Select location, population, Max(total_cases) as HighestInfectionCount, max(total_cases / population)*100 as InfectedRate, max(total_deaths) /max( total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
Group By location, population
Order by InfectedRate desc


-- Showing countries witht he highest death count per population
-- First problem encountered is data type of total_deaths
-- There are aggregated number in the data set too hence needed to only look for data where continent is null
-- United States has the highest death count from Covid of 997,503
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is not null
Group By location
Order by TotalDeathCount desc


-- Breaking it down it down by continent

-- -- Showing continents with the highest death counts per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is not null 
-- And location = 'Singapore'
Group By continent
Order by TotalDeathCount desc

--------------------------------------------------------------------Part 2: Total covid case and Vaccination --------------------------------------------------------------------

-- Looking at Total Population vs vaccination
-- Here I am looking at new vaccination numbers by day and the total vaccinated after each new vaccination as total rolling vaccination numbers
-- As of 7 May 2022, Singapore has 13,996,469 vaccination (both first vaccination and booster)
-- What else I want to know is how quickly singapore manage to provide vaccinations to the whole population. hence the next part.
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
-- The problem that I faced here is that I want to use created columns in another column. Hence, required to use CTE as a solution.
-- Here we get to see Singapore has provided 255% vaccinations to their whole population. 
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

-- Looking at Global scale
-- The top 5 countries with highest percentage of vacination per populations are: 
-- 1. Cuba
-- 2. Chile
-- 3. Gibraltar
-- 4. Singapore
-- 5. South Korea

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
--and cd.location = 'Singapore'
)
Select Continent, location,population, max(total_rolling_vaccinated) as max_vaccinated, max(Total_Rolling_vaccinated/population)*100 as Rolling_Vaccinated_Percentage
From PopvsVac
group by continent, location, population
order by 5 desc

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
