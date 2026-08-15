-- ============================================================
-- TFM: Análisis del Mercado Laboral en Datos y Analytics
-- Christian Escribano Castro
-- Fase 1: Modelado y consultas SQL en Google BigQuery
--
-- 03 · VISTA ANALÍTICA MAESTRA (versión definitiva, cierre de la Fase 1)
-- Integra las 9 tablas mediante CTEs (Common Table Expressions).
-- Esta vista es la fuente de datos para todas las fases siguientes
-- (Python/Colab, Text Mining, Machine Learning, Power BI).
--
-- Problemas técnicos resueltos:
--   - job_skills, job_industries y benefits tienen relación
--     muchos-a-uno con las ofertas -> aplanadas con STRING_AGG(DISTINCT ...)
--   - employee_counts es un histórico con varias fotos por empresa ->
--     se toma solo la más reciente con ROW_NUMBER() + QUALIFY
--   - postings.company_id (FLOAT64) vs companies.company_id (INT64) ->
--     corregido con SAFE_CAST
--   - listed_time viene en formato "epoch" (milisegundos) -> convertido
--     a fecha real con TIMESTAMP_MILLIS + DATE()
-- ============================================================

CREATE OR REPLACE VIEW `tfm-mercado-laboral-datos.mercado_laboral_datos.vista_maestra_mercado_laboral` AS

WITH ofertas_datos AS (
  SELECT
    job_id,
    SAFE_CAST(company_id AS INT64) AS company_id,
    title,
    description,
    skills_desc,
    formatted_work_type,
    formatted_experience_level,
    remote_allowed,
    location,
    views,
    applies,
    listed_time,
    DATE(TIMESTAMP_MILLIS(SAFE_CAST(listed_time AS INT64))) AS fecha_publicacion,
    CASE
      WHEN LOWER(title) LIKE '%data analyst%' THEN 'Data Analyst'
      WHEN LOWER(title) LIKE '%data scientist%' OR LOWER(title) LIKE '%data science%' THEN 'Data Scientist'
      WHEN LOWER(title) LIKE '%data engineer%' THEN 'Data Engineer'
      WHEN LOWER(title) LIKE '%machine learning%' THEN 'Machine Learning Engineer'
      WHEN LOWER(title) LIKE '%data architect%' OR LOWER(title) LIKE '%data modeler%' THEN 'Data Architect'
      WHEN LOWER(title) LIKE '%power bi%' OR LOWER(title) LIKE '%business intelligence%' THEN 'BI Analyst / Developer'
      WHEN LOWER(title) LIKE '%business analyst%' THEN 'Business Analyst'
      ELSE 'Otro / No aplica'
    END AS categoria_rol
  FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.postings`
),

skills_por_oferta AS (
  SELECT
    js.job_id,
    STRING_AGG(DISTINCT s.skill_name, ', ') AS skills_lista
  FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.job_skills` js
  LEFT JOIN `tfm-mercado-laboral-datos.mercado_laboral_datos.skills` s
    ON js.skill_abr = s.skill_abr
  GROUP BY js.job_id
),

industrias_por_oferta AS (
  SELECT
    ji.job_id,
    STRING_AGG(DISTINCT COALESCE(i.industry_name, 'Industria sin especificar'), ', ') AS industrias_lista
  FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.job_industries` ji
  LEFT JOIN `tfm-mercado-laboral-datos.mercado_laboral_datos.industries` i
    ON ji.industry_id = i.industry_id
  GROUP BY ji.job_id
),

beneficios_por_oferta AS (
  SELECT
    job_id,
    STRING_AGG(DISTINCT type, ', ') AS beneficios_lista
  FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.benefits`
  GROUP BY job_id
),

empresa_actual AS (
  SELECT company_id, employee_count, follower_count, time_recorded
  FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.employee_counts`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY time_recorded DESC) = 1
)

SELECT
  o.job_id,
  o.title,
  o.categoria_rol,
  o.description,
  o.skills_desc,
  o.formatted_work_type,
  o.formatted_experience_level,
  o.remote_allowed,
  o.location,
  o.views,
  o.applies,
  o.fecha_publicacion,
  c.name AS empresa,
  c.company_size,
  c.state AS empresa_estado,
  c.country AS empresa_pais,
  ea.employee_count,
  ea.follower_count,
  sk.skills_lista,
  ind.industrias_lista,
  b.beneficios_lista,
  sa.min_salary,
  sa.med_salary,
  sa.max_salary,
  sa.pay_period,
  sa.currency
FROM ofertas_datos o
LEFT JOIN `tfm-mercado-laboral-datos.mercado_laboral_datos.companies` c ON o.company_id = c.company_id
LEFT JOIN empresa_actual ea ON o.company_id = ea.company_id
LEFT JOIN skills_por_oferta sk ON o.job_id = sk.job_id
LEFT JOIN industrias_por_oferta ind ON o.job_id = ind.job_id
LEFT JOIN beneficios_por_oferta b ON o.job_id = b.job_id
LEFT JOIN `tfm-mercado-laboral-datos.mercado_laboral_datos.salaries` sa ON o.job_id = sa.job_id
WHERE o.categoria_rol != 'Otro / No aplica';

-- --------------------------------------------------------------
-- VALIDACIÓN (15 ago 2026)
-- --------------------------------------------------------------
SELECT
  COUNT(*) AS total_filas,
  COUNT(DISTINCT job_id) AS job_ids_distintos,
  MIN(fecha_publicacion) AS fecha_minima,
  MAX(fecha_publicacion) AS fecha_maxima
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.vista_maestra_mercado_laboral`;

-- Resultado: total_filas = job_ids_distintos = 2.163 -> sin duplicados.
-- fecha_minima = 2024-04-05, fecha_maxima = 2024-04-20 (dentro de la
-- ventana real del dataset, ver 01_exploracion_y_calidad_datos.sql).
--
-- Tasa de nulos sobre 2.163 filas:
--   formatted_experience_level: 631 (29%)
--   beneficios_lista:          1.816 (84%) -- más alto que el 45% del mercado general
--   min_salary:                1.541 (71%) -- coherente con el 67% del mercado general
--   skills_lista:                  38 (<2%)
--   industrias_lista:              14 (<1%)
--
-- FASE 1 CERRADA. Esta vista es la fuente de datos para todas las fases
-- siguientes (Python/Colab, Text Mining, Machine Learning, Power BI).
