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
	    count(p.payment_id) AS total_rentals,
	    sum(p.amount) AS total_amount,
	    max(p.payment_date) AS last_rental_date
	from payment p
	left join customer c on p.customer_id = c.customer_id
	left join address a on c.address_id = a.address_id
	left join city c2 on a.city_id = c2.city_id
	left join country c3 on c2.country_id = c3.country_id
	group by p.customer_id, c3.country
)	

select 
	p.*,
	count(p.payment_id) over (partition by p.customer_id) as cnt
from payment p
left join customer c on p.customer_id = c.customer_id
left join address a on c.address_id = a.address_id
left join city c2 on a.city_id = c2.city_id
left join country c3 on c2.country_id = c3.country_id
where cnt = customer_info.total_rentals --почему не сработало , из за порядка следования частей запроса?



