--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.

--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
CREATE TABLE language (
    language_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
INSERT INTO language (name) VALUES ('русский');
INSERT INTO language (name) VALUES ('французский');
INSERT INTO language (name) VALUES ('немецкий');
INSERT INTO language (name) VALUES ('чешский');
INSERT INTO language (name) VALUES ('китайский');
INSERT INTO language (name) VALUES ('бурятский');


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
CREATE TABLE ethnicity (
    ethnicity_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
-- Вставка данных в таблицу ethnicity
INSERT INTO ethnicity (name) VALUES ('славяне');
INSERT INTO ethnicity (name) VALUES ('англосаксы');
INSERT INTO ethnicity (name) VALUES ('германцы');
INSERT INTO ethnicity (name) VALUES ('романцы');
INSERT INTO ethnicity (name) VALUES ('кельты');



--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
CREATE TABLE country (
    country_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
INSERT INTO country (name) VALUES ('Россия');
INSERT INTO country (name) VALUES ('Германия');
INSERT INTO country (name) VALUES ('Франция');
INSERT INTO country (name) VALUES ('Великобритания');
INSERT INTO country (name) VALUES ('Китай');


--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
CREATE TABLE language_ethnicity (
    language_id INT NOT NULL,
    ethnicity_id INT NOT NULL,
    PRIMARY KEY (language_id, ethnicity_id),
    FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE CASCADE,
    FOREIGN KEY (ethnicity_id) REFERENCES ethnicity (ethnicity_id) ON DELETE CASCADE
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (1, 1); 
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (1, 2); 
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (2, 3); 
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (3, 3); 
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (4, 1);
INSERT INTO language_ethnicity (language_id, ethnicity_id) VALUES (5, 5);


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
CREATE TABLE ethnicity_country (
    ethnicity_id INT NOT NULL,
    country_id INT NOT NULL,
    PRIMARY KEY (ethnicity_id, country_id),
    FOREIGN KEY (ethnicity_id) REFERENCES ethnicity (ethnicity_id) ON DELETE CASCADE,
    FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE CASCADE
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (1, 1); 
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (1, 2); 
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (2, 4); 
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (3, 2); 
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (4, 1); 
INSERT INTO ethnicity_country (ethnicity_id, country_id) VALUES (5, 5); 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
-- Создание таблицы film_new
CREATE TABLE IF NOT EXISTS film_new (
    film_name VARCHAR(255) NOT NULL,
    film_year INTEGER CHECK (film_year > 0),
    film_rental_rate NUMERIC(4,2) DEFAULT 0.99,
    film_duration INTEGER NOT NULL CHECK (film_duration > 0)
);



--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]



--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
INSERT INTO film_new (film_name, film_year, film_rental_rate, film_duration)
SELECT 
    unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']) AS film_name,
    unnest(array[1994, 1999, 1985, 1994, 1993]) AS film_year,
    unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]) AS film_rental_rate,
    unnest(array[142, 189, 116, 142, 195]) AS film_duration;


--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

DELETE FROM film_new
WHERE film_name = 'Back to the Future';

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
INSERT INTO film_new (film_name, film_year, film_rental_rate, film_duration)
VALUES ('Москва слезан не верит', 1979, 5.0, 148);


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
SELECT 
	*,
    ROUND(film_duration / 60.0, 1) AS duration_hours
FROM 
    film_new;


--ЗАДАНИЕ №7 
--Удалите таблицу film_new
DROP TABLE IF EXISTS film_new;