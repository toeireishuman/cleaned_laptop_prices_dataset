
---- create separate tables for laptops sales data

SELECT *
FROM laptop_sales.laptops;

CREATE TABLE laptops_staging
LIKE laptop_sales.laptops;

INSERT INTO laptop_sales.laptops_staging
SELECT *
FROM laptop_sales.laptops;

SELECT *
FROM laptop_sales.laptops_staging;

-- rename first column to id
ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN `Unnamed: 0` TO id;

-- rename Weight column to weight_kg
ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN Weight TO Weight_kg;

-- rename Ram column to Ram_gb
ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN Ram TO Ram_gb;

-- obtain all column names
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'laptop_sales' AND
	table_name = 'laptops_staging';

WITH column_names AS (
	SELECT column_name
	FROM information_schema.columns
	WHERE table_schema = 'laptop_sales' AND
		table_name = 'laptops_staging'
)
SELECT 
	CONCAT('ALTER TABLE laptops_staging RENAME ', column_name, ' TO ', LOWER(column_name))
FROM column_names;

---- Delete blank rows

-- identify rows with blank ids
SELECT *
FROM laptop_sales.laptops_staging
WHERE id = '';

-- delete ows with blank ids
DELETE
FROM laptop_sales.laptops_staging
WHERE id = '';

SELECT *
FROM laptop_sales.laptops_staging;


---- Update id to start with 1

UPDATE laptop_sales.laptops_staging
SET id = id + 1;

SELECT *
FROM laptop_sales.laptops_staging;


---- Remove weight unit from Weight_kg

SELECT REPLACE(weight_kg, "kg", "")
FROM laptop_sales.laptops_staging;

UPDATE laptop_sales.laptops_staging
SET weight_kg = REPLACE(weight_kg, "kg", "");

SELECT *
FROM laptop_sales.laptops_staging;


---- Remove memory unit from Ram_gb
SELECT REPLACE(Ram_gb, "GB", "")
FROM laptop_sales.laptops_staging;

UPDATE laptop_sales.laptops_staging
SET Ram_gb = REPLACE(Ram_gb, "GB", "");

SELECT *
FROM laptop_sales.laptops_staging;


---- Extract processor speed and place in separate column

SELECT Cpu
FROM laptop_sales.laptops_staging;

SELECT LENGTH(Cpu) - LOCATE(" ", REVERSE(Cpu))
FROM laptop_sales.laptops_staging;

SELECT REPLACE(REPLACE(MID(Cpu, LENGTH(Cpu) - LOCATE(" ", REVERSE(Cpu)) + 1, 7), "GH", ""), "z", "")
FROM laptop_sales.laptops_staging;

ALTER TABLE laptop_sales.laptops_staging
ADD COLUMN Cpu_speed NUMERIC;

ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN Cpu_speed TO Cpu_speed_Ghz;

ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN Cpu_speed_Ghz TO Cpu_speed_GHz;

UPDATE laptop_sales.laptops_staging
Set Cpu_speed_GHz = NULL;

-- CAST(REPLACE(REPLACE(MID(Cpu, LENGTH(Cpu) - LOCATE(" ", REVERSE(Cpu)) + 1, 7), "GH", ""), "z", "") AS FLOAT)

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN Cpu_speed_GHz TEXT;

UPDATE laptop_sales.laptops_staging
Set Cpu_speed_GHz = REPLACE(REPLACE(MID(Cpu, LENGTH(Cpu) - LOCATE(" ", REVERSE(Cpu)) + 1, 7), "GH", ""), "z", "");

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN Cpu_speed_GHz DECIMAL(65, 2);

---- Modify data types for relevant columns

SELECT *
FROM laptop_sales.laptops_staging;

SELECT MAX(LENGTH(Inches))
FROM laptop_sales.laptops_staging;

SELECT Inches
FROM laptop_sales.laptops_staging
WHERE LENGTH(Inches) = 4;

SELECT MAX(LENGTH(Weight_kg))
FROM laptop_sales.laptops_staging;

SELECT Weight_kg
FROM laptop_sales.laptops_staging
WHERE LENGTH(Weight_kg) = 6;

SELECT MAX(LENGTH(Price))
FROM laptop_sales.laptops_staging;

SELECT Price
FROM laptop_sales.laptops_staging
WHERE LENGTH(Price) = 11;

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN id INTEGER,
MODIFY COLUMN Ram_gb INTEGER;

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN Price DECIMAL(65, 4);

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN Weight_kg DECIMAL(65, 4);

ALTER TABLE laptop_sales.laptops_staging
MODIFY COLUMN Inches DECIMAL(65, 1);

-- edit data point where Weight_kg is not a number

-- we find that there is a non-numeric value for Weight_kg
SELECT MIN(Weight_kg)
FROM laptop_sales.laptops_staging;

SELECT *
FROM laptop_sales.laptops_staging
WHERE Weight_kg LIKE '%?%';

UPDATE laptop_sales.laptops_staging
SET Weight_kg = NULL
WHERE id = 209;

SELECT *
FROM laptop_sales.laptops_staging
WHERE Company = 'Dell' AND
	TypeName = 'Ultrabook' AND
    Cpu LIKE '%Core%7%' AND
    Ram_gb = 8 AND
    Gpu LIKE '%UHD%'
    AND Inches = 13.3 AND
    ScreenResolution LIKE '%Full%';

--

-- we find that there is a non-numeric value for Inches
SELECT MIN(Inches)
FROM laptop_sales.laptops_staging;

SELECT *
FROM laptop_sales.laptops_staging
WHERE Inches LIKE '%?%';

UPDATE laptop_sales.laptops_staging
SET Inches = NULL
WHERE id = 477;

---- Delete duplicate rows

SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY id) AS ranking
FROM laptop_sales.laptops_staging
ORDER BY LENGTH(id);

-- we find that there are no duplicate rows
SELECT *
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY id) AS ranking
	FROM laptop_sales.laptops_staging
	ORDER BY LENGTH(id)
) AS rankings
WHERE ranking > 1;

----
SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory LIKE '%SSD%' AND
	Memory NOT LIKE '%HDD%' AND
    Memory NOT LIKE '%Flash%';

SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory NOT LIKE '%Flash%';
    
SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory NOT LIKE '%SSD%' AND
	Memory NOT LIKE '%HDD%' AND
    Memory LIKE '%Flash%';

SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory NOT LIKE '%Flash%';

-- no rows returned
SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory LIKE '%SSD%' AND
	Memory NOT LIKE '%HDD%' AND
    Memory LIKE '%Flash%';

SELECT id, Memory
FROM laptop_sales.laptops_staging
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory LIKE '%Flash%';

ALTER TABLE laptop_sales.laptops_staging
ADD COLUMN ssd_memory TEXT,
ADD COLUMN hhd_memory TEXT,
ADD COLUMN flash_memory TEXT;

ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN hhd_memory TO hdd_memory;

SELECT *
FROM laptop_sales.laptops_staging;


UPDATE laptop_sales.laptops_staging
SET ssd_memory = Memory
WHERE Memory LIKE '%SSD%' AND
	Memory NOT LIKE '%HDD%' AND
	Memory NOT LIKE '%Flash%';
    
UPDATE laptop_sales.laptops_staging
SET hdd_memory = Memory
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
	Memory NOT LIKE '%Flash%';
    
UPDATE laptop_sales.laptops_staging
SET flash_memory = Memory
WHERE Memory NOT LIKE '%SSD%' AND
	Memory NOT LIKE '%HDD%' AND
	Memory LIKE '%Flash%';

UPDATE laptop_sales.laptops_staging
SET 
	ssd_memory = LEFT(Memory, LOCATE('+', Memory) - 2),
    hdd_memory = RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2)
WHERE Memory LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
	Memory NOT LIKE '%Flash%';


SELECT 
	id, Memory,
    LEFT(Memory, LOCATE('+', Memory) - 2),
    LENGTH(LEFT(Memory, LOCATE('+', Memory) - 2)),
    RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2), 
    LENGTH(RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2))
FROM laptop_sales.laptops_staging
WHERE Memory LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory NOT LIKE '%Flash%';


UPDATE laptop_sales.laptops_staging
SET 
	flash_memory = LEFT(Memory, LOCATE('+', Memory) - 2),
    hdd_memory = RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2)
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
	Memory LIKE '%Flash%';

SELECT 
	id, Memory,
    LEFT(Memory, LOCATE('+', Memory) - 2),
    LENGTH(LEFT(Memory, LOCATE('+', Memory) - 2)),
    RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2), 
    LENGTH(RIGHT(Memory, LENGTH(Memory) - LOCATE('+', Memory) - 2))
FROM laptop_sales.laptops_staging
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory LIKE '%Flash%';

SELECT *
FROM laptop_sales.laptops_staging
WHERE Memory NOT LIKE '%SSD%' AND
	Memory LIKE '%HDD%' AND
    Memory LIKE '%Flash%';

---- editing the OpSys column

-- this query should return rows where there is no provided OS
SELECT *
FROM laptop_sales.laptops_staging
WHERE OpSys IS NULL;

-- returns rows with no provided OS
SELECT *
FROM laptop_sales.laptops_staging
WHERE OpSys LIKE '%no%';

UPDATE laptop_sales.laptops_staging
SET OpSys = NULL
WHERE OpSys LIKE '%no%';


---- rename columns

ALTER TABLE laptop_sales.laptops_staging
RENAME COLUMN Company TO company,
RENAME COLUMN TypeName TO type_name,
RENAME COLUMN Inches TO inches,
RENAME COLUMN ScreenResolution TO screen_resolution,
RENAME COLUMN Cpu TO cpu,
RENAME COLUMN Ram_gb TO ram_gb,
RENAME COLUMN Memory TO total_memory,
RENAME COLUMN Gpu TO gpu,
RENAME COLUMN OpSys TO operating_system,
RENAME COLUMN Weight_kg TO weight_kg,
RENAME COLUMN Price TO price,
RENAME COLUMN Cpu_speed_GHz TO cpu_speed_GHz;


---- set other '?' to NULLs

SELECT *
FROM laptop_sales.laptops_staging
WHERE total_memory = '?';

UPDATE laptop_sales.laptops_staging
SET total_memory = NULL
WHERE total_memory = '?';


SELECT *
FROM laptop_sales.laptops_staging
WHERE ssd_memory IS NOT NULL AND
	hdd_memory IS NOT NULL;
    
---- change order of columns

ALTER TABLE `laptop_sales`.`laptops_staging` 
CHANGE COLUMN `cpu_speed_GHz` `cpu_speed_GHz` DECIMAL(65,2) NULL DEFAULT NULL AFTER `cpu`,
CHANGE COLUMN `ssd_memory` `ssd_memory` TEXT NULL DEFAULT NULL AFTER `total_memory`,
CHANGE COLUMN `hdd_memory` `hdd_memory` TEXT NULL DEFAULT NULL AFTER `ssd_memory`,
CHANGE COLUMN `flash_memory` `flash_memory` TEXT NULL DEFAULT NULL AFTER `hdd_memory`;


---- add cpu brand

SELECT *
FROM laptop_sales.laptops_staging;

SELECT
	LEFT(cpu, LOCATE(" ", cpu)-1)
FROM laptop_sales.laptops_staging;

ALTER TABLE laptop_sales.laptops_staging
ADD COLUMN cpu_brand TEXT;

ALTER TABLE laptop_sales.laptops_staging
CHANGE COLUMN cpu_brand cpu_brand TEXT NULL DEFAULT NULL AFTER cpu;

UPDATE laptop_sales.laptops_staging
SET
	cpu_brand = LEFT(cpu, LOCATE(" ", cpu)-1);

SELECT 
	DISTINCT cpu_brand
FROM laptop_sales.laptops_staging;