
--1. 
   -- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
   
  select npi, sum(total_claim_count) as total_no_of_claims
from prescription
group by npi
order by total_no_of_claims desc
limit 1;
  
    
 -- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
   
  select nppes_provider_first_name,nppes_provider_last_org_name,specialty_description, sum(total_claim_count) as no_of_claims
from prescription AS p1 inner join prescriber AS p2
USING (npi)
group by nppes_provider_first_name,nppes_provider_last_org_name,specialty_description
order by no_of_claims desc
limit 1;
       
	   
	   
--2. 
 --  a. Which specialty had the most total number of claims (totaled over all drugs)?
  
select specialty_description,sum(total_claim_count) as most_no_of_claims
from prescription AS p1 inner join prescriber AS p2
USING (npi)
group by specialty_description
order by most_no_of_claims desc
limit 1;

    --b. Which specialty had the most total number of claims for opioids?
	
select specialty_description, sum(total_claim_count) as most_no_of_claims
  from prescription AS p1 
       	inner join prescriber AS p2
       		using (npi) 
		inner join drug d 
			using (drug_name)
 where d.opioid_drug_flag = 'Y'
 group by specialty_description
 order by most_no_of_claims desc
 limit 1;


    --c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- option 1


select distinct specialty_description 
  from prescriber
except
select distinct specialty_description 
  from prescription p1 
   			join prescriber p2
       			using (npi);


-- other way to do it
select distinct specialty_description 
  from prescriber
where specialty_description not in 
        (select distinct specialty_description 
           from prescription p1 
   			      join prescriber p2
       			    using (npi));
	

   -- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!
   --* For each specialty, report the percentage of total claims by that specialty which are for opioids. 
   --Which specialties have a high percentage of opioids?

 select specialty_description, round(sum(total_claim_count)*100/(select sum(total_claim_count)from prescription),2) as total_per_claim
from prescriber as p1 inner join prescription as p2
                   using (npi) 
                   inner join drug as d 
                 using(drug_name)
where opioid_drug_flag = 'Y'
group by specialty_description
order by total_per_claim desc;

     

--3. 
    --a. Which drug (generic_name) had the highest total drug cost?
	
	
select generic_name, round(sum(total_drug_cost),2) as highest_total_drug_cost
  from drug as d inner join prescription as p
                       using(drug_name)
 group by generic_name
 order by highest_total_drug_cost desc 
 limit 1;
 
 
 


    --b. Which drug (generic_name) has the hightest total cost per day? 
	
select generic_name, (sum(total_drug_cost)/sum(total_day_supply)) as highest_total_drug_cost
from drug as d inner join prescription as p
using(drug_name)
group by generic_name
order by highest_total_drug_cost desc 
limit 1;

		
	--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
		
select generic_name, round((sum(total_drug_cost)/sum(total_day_supply)),2) as highest_total_drug_cost
from drug as d inner join prescription as p
using(drug_name)
group by generic_name
order by highest_total_drug_cost desc 
limti 1;





--4. 
   -- a. For each drug in the drug table, 
   --return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
   --says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
   
   select drug_name,
   case when opioid_drug_flag = 'Y' then 'opiod'
        when antibiotic_drug_flag= 'Y' then 'antibiotic'
		else 'neither'
		end drug_type
from drug ;

   
  ---  b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
  --Hint: Format the total costs as MONEY for easier comparision.
  
  select sum(p.total_drug_cost) ::money as total_cost,
   case when opioid_drug_flag = 'Y' then 'opiod'
        when antibiotic_drug_flag= 'Y' then 'antibiotic' 
		else 'neither'
		end as drug_type
from drug as d inner join prescription as p
using(drug_name)
group by drug_type
order by total_cost desc;
            
  

--5. 
    --a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
	
	select count(distinct cbsa)
	from cbsa
	where cbsaname like '%TN%';

select distinct cbsaname 
from cbsa left join fips_county
using(fipscounty)
where state ='TN';

    --b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	
	
	select cbsaname,sum(population)as largest_total_population
	from population p join cbsa c
	 using (fipscounty)
	group by cbsaname
	order by largest_total_population desc
	limit 1;
	
	select cbsaname,sum(population)as smallest_total_population
	from population p join cbsa c
	 using (fipscounty)
	group by cbsaname
	order by smallest_total_population 
	limit 1;
	
	

    --c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
		
select county, population
  from fips_county join population
	              using (fipscounty)
 where county in ( select county
	                 from fips_county	 
	               except
	               select county
	                 from fips_county join cbsa
				                       using (fipscounty))
order by population desc
limit 1 ; 			
	

--6. 
    --a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
         
		 select drug_name,total_claim_count
          from prescription
		  where total_claim_count >= 3000;
		 
		  
		  
   -- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
   
   
select drug_name,total_claim_count,    
       case when opioid_drug_flag = 'Y' then 'opiod'                      
		    else null
	   end as drug_type
  from prescription p join drug d using (drug_name)
 where total_claim_count >= 3000
 order by 2;
   
   

   -- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
   
  
   
    	  select drug_name,total_claim_count, 
		          case when opioid_drug_flag = 'Y' then 'opiod'                      
		else null
		end as drug_type,
		CONCAT(p1.nppes_provider_first_name, ' ', p1.nppes_provider_last_org_name)as prescriber_first_last_name
          from prescription p join drug d using (drug_name)join prescriber as p1
		                                  on p.npi = p1.npi 
		  where total_claim_count >= 3000
		  order by 2;
   
   
   
   
   

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid.
--**Hint:** The results from all 3 parts will have 637 rows.
  --a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') 
  --in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). 
	--**Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

select npi,drug_name
from prescriber cross join drug
where specialty_description = 'Pain Management'
     and nppes_provider_city = 'NASHVILLE'
      and opioid_drug_flag = 'Y';


    --b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
	--You should report the npi, the drug name, and the number of claims (total_claim_count).
    
	 select npi,drug_name,total_claim_count
     from prescriber cross join drug left join prescription
                                using(npi,drug_name)
      where specialty_description = 'Pain Management'
      and nppes_provider_city = 'NASHVILLE'
      and opioid_drug_flag = 'Y';
	
	
    --c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
	
	
	 select npi,drug_name,COALESCE(total_claim_count,0)as total_claim_count
     from prescriber cross join drug left join prescription
                                using(npi,drug_name)
      where specialty_description = 'Pain Management'
      and nppes_provider_city = 'NASHVILLE'
      and opioid_drug_flag = 'Y';
	
	
	
	
	
	
	                  ---------------bonus questions -----------------
	
	
	
	
	
	
	--1. How many npi numbers appear in the prescriber table but not in the prescription table


select count(*) 
  from (select distinct npi
		  from prescriber
		except
		select distinct npi
		  from prescription);



-----2.
   -- a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
    select distinct generic_name,specialty_description,sum(total_claim_count) as t_c_c
	from prescriber as p1 join prescription as p2
	                     using(npi)join drug as d
						 using(drug_name)
   where specialty_description = 'Family Practice'
   group by generic_name ,specialty_description
   order by t_c_c desc
   limit 5;


    --b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.


select distinct generic_name,specialty_description,sum(total_claim_count) as t_c_c
	from prescriber as p1 join prescription as p2
	                     using(npi)join drug as d
						 using(drug_name)
   where specialty_description ilike '%Cardiology%'
   group by generic_name ,specialty_description
   order by t_c_c desc
   limit 5;



    ---c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists?
	---Combine what you did for parts a and b into a single query to answer this question.


 
 select distinct generic_name,specialty_description,sum(total_claim_count) as t_c_c
	from prescriber as p1 join prescription as p2
	                     using(npi)join drug as d
						 using(drug_name)
   where specialty_description = 'Family Practice'
   group by generic_name ,specialty_description

    union all
	
   select distinct generic_name,specialty_description,sum(total_claim_count) as t_c_c
	from prescriber as p1 join prescription as p2
	                     using(npi)join drug as d
						 using(drug_name)
   where specialty_description ilike '%Cardiology%'
   group by generic_name ,specialty_description
   order by t_c_c desc
   limit 5;





---3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
   -- a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. 
   ---Report the npi, the total number of claims, and include a column showing the city.
  
  select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
  from prescriber AS P1 JOIN prescription as p2
                       using (npi)
  where nppes_provider_city = 'NASHVILLE'
  group by p1.npi,nppes_provider_city
   limit 5;
   
   
   
   
	
	--- b. Now, report the same for Memphis.
	
	
	select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
  from prescriber AS P1 JOIN prescription as p2
                       using (npi)
  where nppes_provider_city = 'MEMPHIS'
   group by p1.npi,nppes_provider_city
   limit 5;
	
	
	
	
    --c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.
	
	select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
     from prescriber AS P1 JOIN prescription as p2
                       using (npi)
     where nppes_provider_city = 'KNOXVILLE'
     group by p1.npi,nppes_provider_city  
	 
    union all
	
	select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
     from prescriber AS P1 JOIN prescription as p2
                       using (npi)
    where nppes_provider_city = 'MEMPHIS'
   group by p1.npi,nppes_provider_city
   
   union all
   
	select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
     from prescriber AS P1 JOIN prescription as p2
                       using (npi)
    where nppes_provider_city = 'NASHVILLE'
    group by p1.npi,nppes_provider_city
	
   union all
   
   select p1.npi,nppes_provider_city,sum(total_claim_count)as t_C_C
   from prescriber AS P1 JOIN prescription as p2
                       using (npi)
   where nppes_provider_city = 'CHATTANOOGA'
   group by p1.npi,nppes_provider_city
   order by t_C_C desc
   limit 5;
		
	

---4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.


select county,sum(overdose_deaths)as total_death
from fips_county as fc join overdose_deaths as od
               on fc.fipscounty::numeric = od.fipscounty
where overdose_deaths > (select avg(overdose_deaths)
						from overdose_deaths)			   
group by county
order by total_death desc;




--5.
    --a. Write a query that finds the total population of Tennessee.
	

	
	
	select state,sum(population)AS total_population_TN        
	from population p inner join fips_county fc
	                 using(fipscounty)
	where state = 'TN'
    group by state;
	
	
   -- b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name,
   ---its population, and the percentage of the total population of Tennessee that is contained in that county.
	
	
	select county, state, round(sum(population)*100/(select sum(population)from population),2) as per_county_prcntge_population   
	from population p inner join fips_county fc
	                 using(fipscounty)
	where state = 'TN'
    group by county, state
	order by per_county_prcntge_population desc;
	
	
	