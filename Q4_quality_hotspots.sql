CREATE OR REPLACE VIEW quality_hotspots_2025 AS

WITH machine_stats AS (
    SELECT
        "Plant",
        "MachineID",
        
        AVG("DefectCount"::numeric / NULLIF("ProductionUnits", 0)) AS avg_defect_rate,
        AVG("Temperature") AS avg_temperature,
        AVG("Vibration") AS avg_vibration,
        AVG("Pressure") AS avg_pressure
        
    FROM production_data
    WHERE DATE("Timestamp") BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY "Plant", "MachineID"
),

ranked_data AS (
    SELECT *,
        NTILE(10) OVER (
            PARTITION BY "Plant"
            ORDER BY avg_defect_rate DESC
        ) AS percentile_rank
    FROM machine_stats
)

SELECT
    "Plant",
    "MachineID",
    
    ROUND(avg_defect_rate, 4) AS avg_defect_rate,
    
    -- FIX: cast to numeric before ROUND
    ROUND(avg_temperature::numeric, 2) AS avg_temperature,
    ROUND(avg_vibration::numeric, 2) AS avg_vibration,
    ROUND(avg_pressure::numeric, 2) AS avg_pressure

FROM ranked_data
WHERE percentile_rank = 1;