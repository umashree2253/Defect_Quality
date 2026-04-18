-- Create table
CREATE TABLE production_data (
    Timestamp TIMESTAMP,
    MachineId VARCHAR(50),
    Plant VARCHAR(50),
    Temperature FLOAT,
    Vibration FLOAT,
    Pressure FLOAT,
    EnergyConsumption FLOAT,
    ProductionUnits INT,
    DefectCount INT,
    MaintenanceFlag INT
);

-- Check data
SELECT * FROM production_data LIMIT 10;

-- Daily defect analysis
SELECT 
    DATE(timestamp) AS date,
    plant,
    SUM(defectcount) AS total_defects,
    SUM(productionunits) AS total_units,
    ROUND(
        SUM(defectcount)::numeric / NULLIF(SUM(productionunits), 0), 
        4
    ) AS defect_rate
FROM production_data
GROUP BY DATE(timestamp), plant;

-- Rolling 7-day average
WITH daily_data AS (
    SELECT 
        DATE(timestamp) AS date,
        plant,
        SUM(defectcount)::numeric / NULLIF(SUM(productionunits), 0) AS defect_rate
    FROM production_data
    GROUP BY DATE(timestamp), plant
)
SELECT 
    date,
    plant,
    defect_rate,
    AVG(defect_rate) OVER (
        PARTITION BY plant 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_avg
FROM daily_data;