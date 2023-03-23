##Lab Subqueries
##Luis
use sakila; 

##Q1
select
f.title,
count(*) as 'num_copies'
from inventory i
	inner join film f
		on i.film_id=f.film_id
where f.title='Hunchback Impossible'
;

##Q2
select
f.title
, f.length
from film f #Use an alias to be able to use length
where length > (select avg(length) from film)#Here is the average legnt of movies
order by f.length desc
;

##Q3
select
*
from actor
where actor_id in 
(select actor_id from film_actor fa inner join film f on fa.film_id=f.film_id  where title='Alone Trip')
;

##Q4
select
	c.name as 'Category'
	, f.title as 'Film_title'
    , f.length as 'Movie_length'
from film f
	inner join film_category fc 
		on f.film_id=fc.film_id
	inner join category c 
		on c.category_id=fc.category_id
where c.name='Family'
;

##Q5
select
	first_name
    , last_name
	, email
from customer
where address_id in #list of cutomers_id from Canada
	(select address_id from address where city_id in #List of address_id from Canada
		(select city_id from city where country_id in #List of cities in Canada
			(select country_id from country where country='Canada') #Filter Canada
		)
    )
;


select 
	c.first_name
    , c.last_name
	, c.email
from customer c
	inner join address a 
		on c.address_id=a.address_id
	inner join city 
		on city.city_id=a.city_id
	inner join country
		on country.country_id=city.country_id
where country.country='Canada'        
;

##Q6
select
	a.first_name
    , a.last_name
	, f.title as 'movie_title'
    , f.release_year

from film_actor fc 
	inner join film f #Name film
		on fc.film_id=f.film_id
	inner join actor a #name actor
		on fc.actor_id=a.actor_id
where fc.actor_id in (
	select  t1.actor_id from  #Get actor_id from t1 
		(select distinct fc2.actor_id, count(*) as 'num_films' # count of films for actor order descencing and first row.
		from film_actor fc2
		group by fc2.actor_id 
		order by num_films desc 
		limit 1) as t1) 
order by f.release_year desc
;

##Q7
select 
	f.title as 'movie title' 
from inventory i
	inner join film f #Here I do a join to simplify the query in Inventory I have already film_id
		on i.film_id=f.film_id
where inventory_id in
	(select #All inventory_id for movies rented by that person
		inventory_id
	from rental
	where customer_id in 
		(select t1.customer_id from #Get id
			(select #Customer with bigger total amount paid
				p.customer_id
				, sum(p.amount) as 'total_amt'
			from payment p
			group by p.customer_id
			order by total_amt desc
			limit 1) 
		as t1)
        )
; 

#Customer with bigger total amount paid
select 
p.customer_id, sum(p.amount) as 'total_amt'
from payment p
group by p.customer_id
order by total_amt desc
limit 1
;


##Q8
select #List of customers_id which spent more than the average
	c.first_name
    , c.last_name
    , c.store_id
    , c.email
from (
	select
	customer_id
	, sum(amount) as 'total_amt_spent' # total amt spent per client
	from payment
	group by customer_id) as t2
	inner join customer c 
		on t2.customer_id=c.customer_id

where t2.total_amt_spent > (
	select
		avg(t1.total_amt_spent) as avg_amt_spent # avg amount spent by client in total
	from (
		select
		customer_id
		, sum(amount) as 'total_amt_spent' # total amt spent per client
		from payment
		group by customer_id) as t1)
;