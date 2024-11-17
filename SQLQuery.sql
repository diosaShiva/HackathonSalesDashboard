select * from dbo.locations;
select * from dbo.stolen_vehicles;
select * from dbo.make_details;

-- 6.Скільки крадіжок в середньому відбувається кожного тижня?
SELECT 
    CONVERT(DECIMAL(10, 2), ROUND(COUNT(vehicle_id) * 1.0 / NULLIF(DATEDIFF(DAY, MIN(date_stolen), MAX(date_stolen)) / 7.0, 0), 2)) AS avg_thefts_per_week
FROM 
    dbo.stolen_vehicles;

-- 7.Яка була середня кількість крадіжок восени? Який найпопулярніший тип транспорту був в крадіїв цього сезону?
WITH AutumnThefts AS (
    SELECT *
    FROM dbo.stolen_vehicles
    WHERE MONTH(date_stolen) IN (9, 10, 11) 
)
SELECT 
    CONVERT(DECIMAL(10, 2), ROUND(COUNT(vehicle_id) * 1.0 / NULLIF(DATEDIFF(DAY, MIN(date_stolen), MAX(date_stolen)) / 7.0, 0), 2)) AS avg_thefts_per_week_autumn,
    vehicle_type AS most_popular_vehicle_type,
    COUNT(vehicle_type) AS theft_count
FROM AutumnThefts
GROUP BY vehicle_type
ORDER BY theft_count DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- 8. Скільки транспортних засобів вкрали з поміж трьох найпопулярніших виробників за парні місяці року? (Найпопулярніший виробник - той, 
-- авто якого крадуть найчастіше за весь період спостережень)
WITH TopManufacturers AS (
    SELECT TOP 3
        m.make_id,
        m.make_name,
        COUNT(sv.vehicle_id) AS theft_count
    FROM 
        dbo.stolen_vehicles sv
    INNER JOIN 
        dbo.make_details m ON sv.make_id = m.make_id
    GROUP BY 
        m.make_id, m.make_name
    ORDER BY 
        COUNT(sv.vehicle_id) DESC
),
EvenMonthThefts AS (
    SELECT 
        sv.vehicle_id,
        sv.make_id
    FROM 
        dbo.stolen_vehicles sv
    WHERE 
        MONTH(sv.date_stolen) % 2 = 0
)
SELECT 
    COUNT(emt.vehicle_id) AS even_months_total_thefts
FROM 
    EvenMonthThefts emt
INNER JOIN 
    TopManufacturers tm ON emt.make_id = tm.make_id;


-- 9.Порахуйте кількість вкрадених авто кожного кольору для кожного регіону.
SELECT 
    l.region,
    sv.color,
    COUNT(sv.vehicle_id) AS theft_count
FROM 
    dbo.stolen_vehicles sv
INNER JOIN 
    dbo.locations l ON sv.location_id = l.location_id
GROUP BY 
    l.region, 
    sv.color
ORDER BY 
    l.region, 
    theft_count DESC;