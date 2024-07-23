--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
SELECT 
	p.*,
	row_number() OVER (ORDER BY payment_date),	--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
	ROW_NUMBER() OVER (PARTITION BY  customer_id ORDER BY payment_date), --Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
	SUM(amount) OVER (PARTITION BY  customer_id   ORDER BY payment_date, amount ASC), --Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя
	--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
	--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
	RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC)	
FROM payment p; 




--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.
SELECT 
	p.*,
	amount,
	LAG(amount, 1, 0.) OVER (PARTITION BY customer_id ORDER BY payment_date)
FROM payment p 





--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select
	p.*,
	amount,
	LEAD(amount) over (partition by customer_id) ,
	LEAD(amount) over (partition by customer_id) - amount as delta
FROM payment p ;







--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select
	*	
from(
	select
		customer_id,
		rental_id,
		payment_date,
		amount,
		row_number() over (partition by customer_id order by payment_date DESC)
	from
		payment
) as p
where 
	row_number = 1;




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

SELECT  
    p.*, 
	sum(amount)  over (partition by customer_id,  payment_date::date order by payment_date::date)
FROM payment p
where  EXTRACT(YEAR FROM p.payment_date) = 2005
	and EXTRACT(month  FROM p.payment_date) = 8
-- order by payment_date;
	



--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

select 
	*
from 	
	(select
		p.*,
		DATE_TRUNC('day', p.payment_date),
		row_number() over (partition by customer_id order by payment_date) as r_n
	from payment p) as w 
where date_trunc('day', payment_date) = '2005-08-20'
	  and r_n % 100 = 0
	 



--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
	  
with customer_info as(
	select 
	    p.customer_id,
	    c3.country,
	    count(p.payment_id) AS cont_rentals,
	    sum(p.amount) AS sum_amount,
	    max(p.payment_date) AS last_rental_date
	from payment p
	left join customer c on p.customer_id = c.customer_id
	left join address a on c.address_id = a.address_id
	left join city c2 on a.city_id = c2.city_id
	left join country c3 on c2.country_id = c3.country_id
	group by p.customer_id, c3.country
),
max_numbers_rentals as(
	select 
		max(cont_rentals) as max_count_rentals,
		max(sum_amount) as max_sum_amount,
		max(last_rental_date)::date as max_date_rental
	from customer_info
)


-- 1. покупатель, арендовавший наибольшее количество фильмов
select *
from (
	select
		p.customer_id,
		c.first_name,
		c.last_name,
	    c3.country,
	    count(p.payment_id) over(partition by p.customer_id) as new_cont_rentals,
	    sum(p.amount) over(partition by p.customer_id) AS new_sum_amount,
	    max(p.payment_date) over(partition by p.customer_id) AS new_last_rental_date
	from payment p
		left join customer c on p.customer_id = c.customer_id
		left join address a on c.address_id = a.address_id
		left join city c2 on a.city_id = c2.city_id
		left join country c3 on c2.country_id = c3.country_id
) as x, max_numbers_rentals
where new_cont_rentals = max_numbers_rentals.max_count_rentals
	
 
-- 2. покупатель, арендовавший фильмов на самую большую сумму
with customer_info as(
	select 
	    p.customer_id,
	    c3.country,
	    count(p.payment_id) AS cont_rentals,
	    sum(p.amount) AS sum_amount,
	    max(p.payment_date) AS last_rental_date
	from payment p
	left join customer c on p.customer_id = c.customer_id
	left join address a on c.address_id = a.address_id
	left join city c2 on a.city_id = c2.city_id
	left join country c3 on c2.country_id = c3.country_id
	group by p.customer_id, c3.country
),
max_numbers_rentals as(
	select 
		max(cont_rentals) as max_count_rentals,
		max(sum_amount) as max_sum_amount,
		max(last_rental_date)::date as max_date_rental
	from customer_info
)

select *
from (
	select
		p.customer_id,
		c.first_name,
		c.last_name,
	    c3.country,
	    count(p.payment_id) over(partition by p.customer_id) as new_cont_rentals,
	    sum(p.amount) over(partition by p.customer_id) AS new_sum_amount,
	    max(p.payment_date) over(partition by p.customer_id) AS new_last_rental_date
	from payment p
		left join customer c on p.customer_id = c.customer_id
		left join address a on c.address_id = a.address_id
		left join city c2 on a.city_id = c2.city_id
		left join country c3 on c2.country_id = c3.country_id
) as x, max_numbers_rentals
where new_sum_amount = max_numbers_rentals.max_sum_amount



-- 3. покупатель, который последним арендовал фильм
with customer_info as(
	select 
	    p.customer_id,
	    c3.country,
	    count(p.payment_id) AS cont_rentals,
	    sum(p.amount) AS sum_amount,
	    max(p.payment_date) AS last_rental_date
	from payment p
	left join customer c on p.customer_id = c.customer_id
	left join address a on c.address_id = a.address_id
	left join city c2 on a.city_id = c2.city_id
	left join country c3 on c2.country_id = c3.country_id
	group by p.customer_id, c3.country
),
max_numbers_rentals as(
	select 
		max(cont_rentals) as max_count_rentals,
		max(sum_amount) as max_sum_amount,
		max(last_rental_date)::date as max_date_rental
	from customer_info
)


select *
from (
	select
		p.customer_id,
		c.first_name,
		c.last_name,
	    c3.country,
	    count(p.payment_id) over(partition by p.customer_id) as new_cont_rentals,
	    sum(p.amount) over(partition by p.customer_id) AS new_sum_amount,
	    max(p.payment_date) over(partition by p.customer_id) AS new_last_rental_date
	from payment p
		left join customer c on p.customer_id = c.customer_id
		left join address a on c.address_id = a.address_id
		left join city c2 on a.city_id = c2.city_id
		left join country c3 on c2.country_id = c3.country_id
) as x, max_numbers_rentals
where new_last_rental_date::date = max_numbers_rentals.max_date_rental





--new
WITH customer_info AS (
    SELECT 
        p.customer_id,
        c3.country,
        COUNT(p.payment_id) AS rental_count,
        SUM(p.amount) AS total_amount,
        MAX(p.payment_date) AS last_rental_date,
        c.first_name || ' ' || c.last_name AS customer_name
    FROM payment p
    LEFT JOIN customer c ON p.customer_id = c.customer_id
    LEFT JOIN address a ON c.address_id = a.address_id
    LEFT JOIN city c2 ON a.city_id = c2.city_id
    LEFT JOIN country c3 ON c2.country_id = c3.country_id
    GROUP BY p.customer_id, c3.country, c.first_name, c.last_name
),
max_rentals AS (
    SELECT 
        country,
        MAX(rental_count) AS max_rental_count
    FROM customer_info
    GROUP BY country
),
max_amounts AS (
    SELECT 
        country,
        MAX(total_amount) AS max_total_amount
    FROM customer_info
    GROUP BY country
),
latest_rentals AS (
    SELECT 
        country,
        MAX(last_rental_date) AS max_last_rental_date
    FROM customer_info
    GROUP BY country
)
SELECT 
    ci1.country,
    MAX(CASE WHEN ci1.rental_count = mr.max_rental_count THEN ci1.customer_name END) AS most_rentals_customer,
    MAX(CASE WHEN ci2.total_amount = ma.max_total_amount THEN ci2.customer_name END) AS highest_amount_customer,
    MAX(CASE WHEN ci3.last_rental_date = lr.max_last_rental_date THEN ci3.customer_name END) AS last_rental_customer
FROM 
    customer_info ci1
    LEFT JOIN max_rentals mr ON ci1.country = mr.country
    LEFT JOIN customer_info ci2 ON ci1.country = ci2.country AND ci1.customer_id = ci2.customer_id
    LEFT JOIN max_amounts ma ON ci2.country = ma.country
    LEFT JOIN customer_info ci3 ON ci1.country = ci3.country AND ci1.customer_id = ci3.customer_id
    LEFT JOIN latest_rentals lr ON ci3.country = lr.country
GROUP BY 
    ci1.country
ORDER BY 
    ci1.country;


