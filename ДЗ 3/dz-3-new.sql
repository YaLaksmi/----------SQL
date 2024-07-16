--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select
	concat( c.last_name,' ', c.first_name) as "Customer name",
	a.address,
	ci.city,
	c2.country 
from customer as c
left join address as a
	on c.address_id =  a.address_id 
left join city as ci
	on a.city_id = ci.city_id
left join country as c2
	on ci.country_id  = c2.country_id 



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select
	s.store_id as "ID магазина", 
	count(c.customer_id) as "Количество покупателей"
from customer as c 
left join store as s 
	on c.store_id = s.store_id 
group by s.store_id;



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select
	s.store_id as "ID магазина", 
	count(c.customer_id) as "Количество покупателей"
from customer as c 
left join store as s 
	on c.store_id = s.store_id 
group by s.store_id
having count(c.customer_id) > 300;





-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

-- Группировка по имени и фамилии или названию города - это заведомо ложные данные. Соответственно откорректируйте решения по заданиям 2.3, 3 и 4.

select
	s.store_id as "ID магазина", 
	count(c.customer_id) as "Количество покупателей",
	ci.city  as "Город",
	concat(st.last_name, ' ' , st.first_name) as "Имя сотрудника"
from customer as c 
left join store as s 
	on c.store_id = s.store_id
left join staff as st
	on s.manager_staff_id = st.staff_id 
left join address as a
	on a.address_id = s.address_id 
left join city as ci
	on a.city_id = ci.city_id 
group by s.store_id , ci.city_id, st.staff_id 
having count(c.customer_id) > 300;



--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select 	
	concat(c.last_name, ' ', c.first_name) as "Фамилия и имя покупателя",
	count(p.payment_id) as "Количество фильмов"
from payment as p
left join customer as c
	on c.customer_id = p.customer_id 
group by c.customer_id 
order by count(p.payment_id) desc
limit 5;


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select 	
	concat(c.last_name, ' ', c.first_name) as "Фаимлия и имя покупателя",
	count(p.payment_id) as "Количество фильмов",
	round(sum(p.amount)) as "Общая стоимость платежей",
	min(p.amount) as "Минимальная стоисоть платежей",
	max(p.amount) as "Максимальная стоимость платежей"
from payment as p
left join customer as c
	on c.customer_id = p.customer_id 
group by c.customer_id 
order by concat(c.last_name, ' ', c.first_name);




--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
 select 
 c1.city,
 c2.city
 from city as c1
 	cross join city as c2
where c1.city != c2.city
 	
 




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 

SELECT  customer_id as "ID покупателя",
	round(avg(DATE_PART('day', return_date - rental_date))::numeric, 2) as "Среднее количество дней на возврат"
FROM public.rental
group by customer_id
order by customer_id


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select 
	title as "Название фильма",
	rating as "Рейтинг",
	c."name"  as "Жанр",
	release_year  as "Год выпуска",
	l.name as "Язык",
	count(p.amount)  as "Количество аренд",
	sum(p.amount) as "Общая стоимость арнеды"
from film as f
left join inventory as i
	ON f.film_id = i.film_id 
left join rental as r
	on r.inventory_id = i.inventory_id 
left join "language" as l
	on f.language_id = l.language_id
left join payment as p
	on r.rental_id = p.rental_id
left join film_category as fc 
	on fc.film_id = f.film_id
left join category c 
	on fc.category_id = c.category_id 
group by 
/*
	title ,
	rating ,
	c."name" ,
	release_year ,
	l.name 
*/	
	f.film_id,
	c.category_id,
	l."name" 
	
order by f.title 





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.
select 
	title as "Название фильма",
	rating as "Рейтинг",
	c."name"  as "Жанр",
	release_year  as "Год выпуска",
	l.name as "Язык",
	count(p.amount)  as "Количество аренд",
	sum(p.amount) as "Общая стоимость арнеды"
from film as f
left join inventory as i
	ON f.film_id = i.film_id 
left join rental as r
	on r.inventory_id = i.inventory_id 
left join "language" as l
	on f.language_id = l.language_id
left join payment as p
	on r.rental_id = p.rental_id
left join film_category as fc 
	on fc.film_id = f.film_id
left join category c 
	on fc.category_id = c.category_id 
group by 
/*
	title ,
	rating ,
	c."name" ,
	release_year ,
	l.name 
*/	
	f.film_id,
	c.category_id,
	l."name" 
having count(p.amount) = 0
	and sum(p.amount) is null

order by f.title;


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select 
	staff_id,
	count(payment_id),
	CASE
		when count(payment_id) > 7300 then  'Да'
		else'Нет'
	END
from payment p 
group by staff_id







