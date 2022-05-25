# PortfolioProjects

The Portfolio Projects are a series of exercises that I take to improve my data analysis skills. Beginning with data exploration, I will be moving on to data cleaning and then eventually visualisation. 

## Data Exploration

In this project, I am exploring data relating to covid-19 from Jan 2020 to May 2022.
The exploration revolves total cases, total deaths and vaccination number around the globe and Singapore.

Source: https://ourworldindata.org/covid-deaths

## Data Cleaning

The data I am using is a random data sample but this exercise focuses more on the different data cleaning techniques that I can employ.

1. Standaradize date format
2. Populate Property Address data
    a)Using join to itself
3. Breaking out address  into individual columns (Address, City, States)
		a) Substring, Charindex
		b) Alternative method using Parsename & Replace (Simpler and more effective)
4. Change Y and N to Yes and No in "Sold as Vacant" field
5. Remove duplicates
		a) Using CTE and Rownum() & OVER Partition by
6. Delete some unused columns
		a) Using Drop
