SELECT *
FROM [Covid Database]..CovidDeaths$;

SELECT *
FROM CovidVaccinations$;

--Total cases vs Total Deaths
SELECT Location
, Date
, total_cases
, new_cases
, total_deaths
, ROUND((total_deaths/total_cases)*100,2) AS"Death_Ratio"
FROM [Covid Database]..CovidDeaths$
ORDER BY 1,2;

--Total cases vs Population
SELECT Location
, Date
, total_cases
, population
, ROUND((total_cases/population)*100,2) AS"case_Ratio"
FROM [Covid Database]..CovidDeaths$
--WHERE location = 'India'
ORDER BY 1,2;

-- Countries with the Highest Infection rate compared to population

SELECT Location
, MAX(total_cases) AS "Infection Count"
, population
, MAX(ROUND((total_cases/population)*100,2)) AS"case_Ratio"
FROM [Covid Database]..CovidDeaths$
GROUP BY Location, Population
ORDER BY case_Ratio DESC;

-- Countries with the Highest Death count compared to population

SELECT Location
, continent
, MAX(total_deaths) AS "Death Count"
, population
, MAX(ROUND((total_deaths/population)*100,2)) AS "death_Ratio"
FROM [Covid Database]..CovidDeaths$
WHERE continent != 'NULL'
GROUP BY Location
, continent
, Population
ORDER BY death_Ratio DESC;

--Death Count based on continenet

WITH CTE  AS(
SELECT Location
, continent
, MAX(CAST(total_deaths as int)) AS 'totaldeath'
FROM [Covid Database]..CovidDeaths$
WHERE continent != 'NULL' AND total_deaths != 'NULL'
GROUP BY Location
, continent
)

SELECT DISTINCT continent
,SUM(totaldeath) AS 'death_count'
FROM CTE
GROUP BY continent
ORDER BY 2 DESC;

-- Population vs  Vaccinations (cummulative method)

WITH CTE as(
SELECT dea.Location
, dea.date
, dea.population
, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as 'cummilative_total_vaccination'
FROM [Covid Database]..CovidDeaths$ dea
LEFT JOIN [Covid Database]..CovidVaccinations$ vac
ON vac.location = dea.location
AND vac.date = dea.date
WHERE dea.continent is not NULL)

SELECT *
, (cummilative_total_vaccination/population)*100
FROM CTE