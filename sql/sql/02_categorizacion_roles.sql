-- ============================================================
-- TFM: Análisis del Mercado Laboral en Datos y Analytics
-- Christian Escribano Castro
-- Fase 1: Modelado y consultas SQL en Google BigQuery
--
-- 02 · CATEGORIZACIÓN DE ROLES (CASE WHEN) — VERSIÓN DEFINITIVA
-- Objetivo: postings.csv NO es un dataset exclusivo de datos y analytics,
-- es un dataset de empleo general (123.849 ofertas de todos los sectores).
--
-- Proceso: se probó primero una búsqueda amplia por palabras sueltas
-- ("data", "analyst"), que resultó demasiado imprecisa (capturaba, por
-- ejemplo, Financial Analyst, Board Certified Behavior Analyst, Data
-- Entry Clerk, Data Center Technician/Operations, Database
-- Administrator...) porque compartían palabras sueltas sin ser roles
-- reales de datos y analytics. Se sustituyó por una búsqueda de frases
-- exactas, mucho más precisa.
--
-- Decisiones de alcance documentadas:
--   - Se incluye "Business Analyst" como categoría propia: rol de
--     entrada realista y accesible, relevante para el caso de uso del
--     propio alumno en la Fase 6 (productivización).
--   - Se excluye "Database Administrator": perfil de infraestructura,
--     bajo volumen (33 ofertas), no encaja con el enfoque de analytics.
-- ============================================================

SELECT
  CASE
    WHEN LOWER(title) LIKE '%data analyst%' THEN 'Data Analyst'
    WHEN LOWER(title) LIKE '%data scientist%' OR LOWER(title) LIKE '%data science%' THEN 'Data Scientist'
    WHEN LOWER(title) LIKE '%data engineer%' THEN 'Data Engineer'
    WHEN LOWER(title) LIKE '%machine learning%' THEN 'Machine Learning Engineer'
    WHEN LOWER(title) LIKE '%data architect%' OR LOWER(title) LIKE '%data modeler%' THEN 'Data Architect'
    WHEN LOWER(title) LIKE '%power bi%' OR LOWER(title) LIKE '%business intelligence%' THEN 'BI Analyst / Developer'
    WHEN LOWER(title) LIKE '%business analyst%' THEN 'Business Analyst'
    ELSE 'Otro / No aplica'
  END AS categoria_rol,
  COUNT(*) AS num_ofertas
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.postings`
GROUP BY categoria_rol
ORDER BY num_ofertas DESC;

-- Resultado final (15 ago 2026), total 123.849 (cuadra con el total de la tabla):
-- Otro / No aplica          121.686
-- Business Analyst              553
-- Data Analyst                  408
-- Data Engineer                 397
-- Data Scientist                349
-- BI Analyst / Developer        188
-- Machine Learning Engineer     135
-- Data Architect                133
-- -----------------------------------
-- TOTAL ofertas de datos y analytics: 2.163 (1,75% del total)
-- Decisión: la vista analítica maestra (03_vista_maestra.sql) filtra
-- SOLO estas 2.163 ofertas (categoria_rol != 'Otro / No aplica'), ya que
-- el alcance del TFM es específicamente el sector de datos y analytics.
