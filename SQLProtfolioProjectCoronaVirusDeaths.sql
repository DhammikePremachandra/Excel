Select * 
From public."CovidDeaths"
Where continent is not null
Order by 3,4


Select * 
From public."CovidVaccinations"
Where continent is not null
Order by 3,4


--selecting data that is going to use
Select location, date, population,total_cases, new_cases, total_deaths
From public."CovidDeaths"
Where continent is not null
Order by 1,2


--Exploring Total Cases vs Total Deaths
Select location, date,total_cases, total_deaths, 
(total_deaths::numeric/total_cases::numeric)*100 as Deaths_rate
From public."CovidDeaths"
Where location like 'Sri Lanka'
and continent is not null
Order by 1,2


--Exploring Total Cases vs Population
Select location, date,total_cases, population, 
(total_cases::numeric/population::numeric)*100 as infection_rate
From public."CovidDeaths"
Where continent is not null
Order by 1,2


--Exploring countries with highest infection rate compared to the population
Select location, Max(total_cases) as highest_infection_count, population, 
Max((total_cases::numeric/population::numeric))*100 as infection_rate
From public."CovidDeaths"
Where continent is not null
Group by location, population
Order by infection_rate desc


--Exploring countries with highest death count as per the population
Select location, Max(cast(total_deaths as INT)) as total_deaths_count
From public."CovidDeaths"
Where continent is not null
Group by location
Order by total_deaths_count desc


--Exploring continent with highest death count per population
Select continent,Max(cast(total_deaths as INT)) as total_deaths_count
From public."CovidDeaths"
Where continent is not null
Group by continent
Order by total_deaths_count desc


--Exploring global numbers
Select SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, 
(SUM(new_deaths::numeric)/SUM(new_cases::numeric))*100 as death_percentage
From public."CovidDeaths"
Where continent is not null
Order by 1,2

--Exploring global numbers with date
Select date,SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, 
(SUM(new_deaths::numeric)/SUM(new_cases::numeric))*100 as death_percentage
From public."CovidDeaths"
Where continent is not null
Group by date
Order by 1,2


--Exploring total population vs vaccinations using CTE
With popuvsvacc (Continent, Location, Date, Population, New_Vaccinations, rolling_count_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations)  
Over(partition by dea.location order by dea.location, dea.date) as rolling_count_people_vaccinated
From public."CovidDeaths" dea
Join public."CovidVaccinations" vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_count_people_vaccinated/Population)*100 as vaccination_rate
From popuvsvacc


