/*Based on the structure of the crime_scene_report table, we are interested in the description of the crime. 
Thankfully, we know the date, type, and city of the crime so we should be able to filter in order to get only useful data.*/ 

select description
from crime_scene_report
where date = '20180115' AND city = 'SQL city' AND type = 'murder'; 


/*Based on the interview table structure, we will need to know our witnesses’ person_id in order to find their transcript.
According to the schema, the person_id can also be found as id in the person table. 
Since the person table also includes information about names and addresses, we should be able filter the data to find our witnesses.
Let’s start by finding Annabel’s id.*/

select *
from person
where name like 'Annabel%' and address_street_name = 'Franklin AVe';
--This query shows us that Annabel’s id is 16371.


/*Let’s look for our second witness, living at the last house on Northwestern Dr.*/

select *
from person
where address_street_name ='Northwestern Dr'
order by address_number desc
limit 1;
--our second witness is Morty Schapiro, whose id is 14887.


/*Now that we have the ids, we can look for the interview transcripts*/

select transcript
from interview
where person_id = '16371';
--This query taught us that Annabel saw the murder happen. And that the killer is a gym member who came in on January 9, 2018.

select *
from interview
where person_id = '14887';
/*This query confirms that the killer is a gym member, a gold member. 
Morty also said the mand had a gun, a partial membership number: ‘48Z’, and license plate: ‘H42W’.crime_scene_report. 
Finally, we now know that the killer is male. Our investigation is leading us to the gym*/

/*By combining Annabel’s gym check-in date and Morty’s partial gym membership id and membership status,
we should be able to obtain the killer’s full membership id. We can then match this membership id to a name*/


select *
from get_fit_now_member
where membership_status = 'gold' and  get_fit_now_member.id like '48Z%';
/*Two members with ids starting with ‘48Z’ checked-in on January 9th.
We can use information from the get_fit_now_member table to narrow down our list of suspects.*/


select *
from get_fit_now_check_in
where check_in_date = '20180109' AND membership_id in ('48Z7A', '48Z55');
/*It seems like both of our suspects are gold members so we cannot find out who did it based on membership status. 
However we now have names: Joe Germuska and Jeremy Bowers. 
We can use those to find their license plates and see if any of them match Morty’s description*/

/*We can use the person table to match our names to a license id number. 
The license id number can then be used as id in the drivers_license table to look up the license plate number.*/


select *
from drivers_license
where plate_number like '%H42W%';


/*We can use the person table to match our names to a license id number. 
The license id number can then be used as id in the drivers_license table to look up the license plate number.*/


select p.name, d.id
from person as p 
join drivers_license as d
on p.license_id = d.id
where p.name = 'Joe Germuska' or 'Jeremy Bowers';
/* the Query only shows Jeremy Bowers has a car registered, and his license plate matches Morty’s description.
so therefore, Jeremy Bowers*/

/* looking through the interview trascript of the killer, it seems the killer took orders from someone. 
Based on the result from our gym membership query, we know Jeremy Bowers’ person_id: 67318. 
This should be all we need to pull up his interview transcript.*/


select *
from interview 
where person_id = '67318';

/*Jeremy just gave us a lot of information about his boss. We know she is a female, Height between 65" and 67", with red hair and a Tesla Model S. 
We also know she attended the SQL Symphony Concert 3 times in December 2017.*/


select p.name, d.height, d.hair_color, d.car_make, d.car_model, d.gender
from drivers_license as d
join person as p
on d.id = p.license_id
where d.height BETWEEN 65 and 67 AND d.hair_color ='red' 
               AND d.gender ='female' AND d.car_make ='Tesla' 
               AND  d.car_model ='model s'
               AND p.id IN (select f.person_id
                            from facebook_event_checkin as f
                            where f.event_name ='SQL symphony concert');
-- The query above shows that "Miranda Priestly" is the mastermind of the killing.



