### Covid data project SQL code from Dec 2021  
#### This highlights joins, CTEs, and views  
Query done in **Google BigQuery**  
[Data source](https://ourworldindata.org/covid-deaths) extracted December 6th 2021  
  
Saved file as DEC2021_TJS_RAW_PublicCovidData_v00  
Population moved to column E  
Column AA and right deleted  
Saved file as CSV DEC2021_TJS_CovidDeaths_CSV_v00  
Deleted all data except colums A:D  
Saved file as CSV DEC2021_TJS_CovidVaccinations_CSV_v00  
Created dataset covid_dataset_dec2021 in BigQuery  
Created table covid-deaths from DEC2021_TJS_CovidDeaths_CSV_v00  
Created table covid-vaccinations from DEC2021_TJS_CovidVaccinations_CSV_v00  
  
#### [Tableau visualization](https://public.tableau.com/app/profile/tyler.simpson8861/viz/DEC2021_covid_project_dashboard/Dashboard1?publish=yes)  
