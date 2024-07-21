-- 1. Выведите название самолетов, которые имеют менее 50 посадочных мест?
SELECT 
	a.model,
	count(*)
FROM aircrafts as a 
	LEFT JOIN seats as s
		ON a.aircraft_code = s.aircraft_code
GROUP BY a.model  
HAVING count(*) < 50;
	

-- 2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
WITH monthly_totals AS (
    SELECT
        DATE_TRUNC('month', book_date) AS month,
        SUM(total_amount) AS total_amount
    FROM Bookings
    GROUP BY month
    ORDER BY month
),
monthly_changes AS (
    SELECT
        month,
        total_amount,
        LAG(total_amount) OVER (ORDER BY month) AS previous_total_amount
    FROM monthly_totals
)
SELECT
    month,
    ROUND(((total_amount - previous_total_amount) / previous_total_amount) * 100, 2) AS percentage_change
FROM monthly_changes
WHERE previous_total_amount IS NOT NULL;


-- 3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

SELECT
    array_agg(DISTINCT a.model) AS aircrafts_without_business_class
FROM
    Aircrafts a
LEFT JOIN
    Seats s ON a.aircraft_code = s.aircraft_code
GROUP BY
    a.aircraft_code
HAVING
    SUM(CASE WHEN s.fare_conditions = 'Business' THEN 1 ELSE 0 END) = 0;

   
  -- 4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
--  В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.
   
WITH empty_flights AS (
    SELECT
        f.flight_id,
        f.departure_airport,
        f.scheduled_departure::date AS departure_date,
        a.aircraft_code,
        COUNT(s.seat_no) AS empty_seats
    FROM
        Flights f
    JOIN
        Aircrafts a ON f.aircraft_code = a.aircraft_code
    LEFT JOIN
        Seats s ON a.aircraft_code = s.aircraft_code
    LEFT JOIN
        Boarding_passes bp ON f.flight_id = bp.flight_id
    WHERE
        bp.ticket_no IS NULL -- Учитываем только пустые места
    GROUP BY
        f.flight_id, f.departure_airport, f.scheduled_departure::date, a.aircraft_code
    HAVING
        COUNT(bp.ticket_no) = 0 -- Учитываем только полностью пустые рейсы
),
flights_per_day AS (
    SELECT
        departure_airport,
        departure_date,
        SUM(empty_seats) AS total_empty_seats,
        COUNT(flight_id) AS num_flights
    FROM
        empty_flights
    GROUP BY
        departure_airport, departure_date
    HAVING
        COUNT(flight_id) > 1 -- Учитываем только дни с более чем одним таким рейсом
),
cumulative_seats AS (
    SELECT
        departure_airport,
        departure_date,
        total_empty_seats,
        SUM(total_empty_seats) OVER (PARTITION BY departure_airport ORDER BY departure_date) AS cumulative_total
    FROM
        flights_per_day
)
SELECT
    departure_airport,
    departure_date,
    total_empty_seats,
    cumulative_total
FROM
    cumulative_seats
ORDER BY
    departure_airport, departure_date;

   
   
-- 5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
 -- Выведите в результат названия аэропортов и процентное отношение.
-- Решение должно быть через оконную функцию.
   
WITH route_counts AS (
    SELECT
        f.departure_airport,
        f.arrival_airport,
        COUNT(*) AS flight_count
    FROM
        Flights f
    GROUP BY
        f.departure_airport, f.arrival_airport
),
total_flights AS (
    SELECT
        SUM(flight_count) OVER () AS total_flight_count
    FROM
        route_counts
    LIMIT 1
),
route_percentages AS (
    SELECT
        r.departure_airport,
        r.arrival_airport,
        r.flight_count,
        t.total_flight_count,
        ROUND((r.flight_count::decimal / t.total_flight_count) * 100, 2) AS percentage
    FROM
        route_counts r,
        total_flights t
)
SELECT
    da.airport_name AS departure_airport_name,
    aa.airport_name AS arrival_airport_name,
    rp.percentage
FROM
    route_percentages rp
JOIN
    Airports da ON rp.departure_airport = da.airport_code
JOIN
    Airports aa ON rp.arrival_airport = aa.airport_code
ORDER BY
    rp.percentage DESC;
   
   
   
   
-- 6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
 SELECT
    SUBSTRING(contact_data FROM '\+7(\d{3})') AS operator_code,
    COUNT(*) AS passenger_count
FROM
    Tickets
GROUP BY
    operator_code
ORDER BY
    passenger_count DESC;  
   
   
SELECT
    SUBSTRING(phone_number FROM 3 FOR 3) AS operator_code,
    COUNT(*) AS passenger_count
FROM
    passengers
GROUP BY
    SUBSTRING(phone_number FROM 3 FOR 3)
ORDER BY
    operator_code;
   
   
   
   
7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
 До 50 млн - low
 От 50 млн включительно до 150 млн - middle
 От 150 млн включительно - high
 Выведите в результат количество маршрутов в каждом полученном классе

 WITH RouteTurnover AS (
    SELECT 
        f.departure_airport,
        f.arrival_airport,
        SUM(tf.amount) AS total_amount
    FROM 
        Flights f
    JOIN 
        Ticket_flights tf
    ON 
        f.flight_id = tf.flight_id
    GROUP BY 
        f.departure_airport, 
        f.arrival_airport
),
ClassifiedRoutes AS (
    SELECT 
        departure_airport,
        arrival_airport,
        total_amount,
        CASE 
            WHEN total_amount < 50000000 THEN 'low'
            WHEN total_amount >= 50000000 AND total_amount < 150000000 THEN 'middle'
            ELSE 'high'
        END AS route_class
    FROM 
        RouteTurnover
)
SELECT 
    route_class,
    COUNT(*) AS route_count
FROM 
    ClassifiedRoutes
GROUP BY 
    route_class;

 
 
 
8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_flight_cost
FROM 
    Ticket_flights;

   
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_booking_size
FROM 
    Bookings;

   
 WITH MedianValues AS (
    SELECT 
        (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) FROM Ticket_flights) AS median_flight_cost,
        (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) FROM Bookings) AS median_booking_size
)
SELECT 
    median_booking_size,
    median_flight_cost,
    ROUND(median_booking_size / median_flight_cost, 2) AS ratio
FROM 
    MedianValues;
  
   








9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
  Для поиска расстояния между двумя точками на поверхности Земли используется модуль earthdistance.
  Для работы модуля earthdistance необходимо предварительно установить модуль cube.
  Установка модулей происходит через команду: create extension название_модуля.
  
  
  
  CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

  
  
 
WITH FlightDistances AS (
    SELECT 
        f.flight_id,
        f.departure_airport,
        f.arrival_airport,
        earth_distance(ll_to_earth(a1.latitude, a1.longitude), ll_to_earth(a2.latitude, a2.longitude)) / 1000 AS distance_km
    FROM 
        Flights f
    JOIN 
        Airports a1 ON f.departure_airport = a1.airport_code
    JOIN 
        Airports a2 ON f.arrival_airport = a2.airport_code
),
FlightCosts AS (
    SELECT 
        f.flight_id,
        fd.distance_km,
        SUM(tf.amount) AS total_flight_cost,
        SUM(tf.amount) / fd.distance_km AS cost_per_km
    FROM 
        Ticket_flights tf
    JOIN 
        Flights f ON tf.flight_id = f.flight_id
    JOIN 
        FlightDistances fd ON f.flight_id = fd.flight_id
    GROUP BY 
        f.flight_id, fd.distance_km
)
SELECT 
    MIN(cost_per_km) AS min_cost_per_km
FROM 
    FlightCosts;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  