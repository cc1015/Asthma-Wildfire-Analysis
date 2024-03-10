-- filter wildfire data set

create view wf_2 as
select incident_name, incident_county, incident_acres_burned, incident_latitude, incident_longitude,
strftime('%Y', incident_dateonly_created) as year
from wf
where incident_county not null

-- total acres burned by year 

select year,
sum(incident_acres_burned) as total_acres_burned
from wf_2 
where year != "2023"
	and year >= "2009"
group by year
order by year ASC

-- merge tables by year and county

create view merged as
select wf.incident_county, wf.year, wf.total_acres_burned, ast.visit_rate, ast.num_visits
from (
 	select incident_county, year, SUM(incident_acres_burned) AS total_acres_burned
 	from wf_2
 	group by year, incident_county
) wf
join (
 	select "COUNTY", "YEAR", 
 	"AGE-ADJUSTED ED VISIT RATE" AS visit_rate, "NUMBER OF ED VISITS" as num_visits
 	from asthma
 	where "COUNTY" != "California"
  		and "STRATA" = "Total population"
 	group by "YEAR", "COUNTY"
) ast 
ON wf.incident_county = ast."COUNTY"
	and wf.year = ast."YEAR"
	
select * from merged

drop view if exists merged

-- extract yearly data (from 2015 to 2019) for acres burned and ED visits

select year,
sum(incident_acres_burned) as total_acres_burned
from wf_2 
where year != "2023"
	and year >= "2015"
    and year <= "2019"
group by year

select year, 
sum(num_visits) as yearly_visits
from merged
group by year




