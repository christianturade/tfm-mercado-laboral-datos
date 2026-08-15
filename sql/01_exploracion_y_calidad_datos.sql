-- ============================================================
-- TFM: Análisis del Mercado Laboral en Datos y Analytics
-- Christian Escribano Castro
-- Fase 1: Modelado y consultas SQL en Google BigQuery
-- Proyecto: tfm-mercado-laboral-datos
-- Dataset:  mercado_laboral_datos
--
-- 01 · EXPLORACIÓN Y CALIDAD DE DATOS
-- Verificación de la carga de las 9 tablas, y diagnóstico de dos
-- incidencias reales de calidad de datos encontradas durante la carga.
-- ============================================================

-- --------------------------------------------------------------
-- 1. Verificación de carga: número de filas por tabla
-- Objetivo: confirmar que las 9 tablas se cargaron correctamente
-- tras el proceso de ingesta (8 vía consola BigQuery, 1 vía Colab).
-- --------------------------------------------------------------
SELECT 'postings' AS tabla, COUNT(*) AS filas FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.postings`
UNION ALL
SELECT 'companies', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.companies`
UNION ALL
SELECT 'employee_counts', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.employee_counts`
UNION ALL
SELECT 'benefits', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.benefits`
UNION ALL
SELECT 'job_industries', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.job_industries`
UNION ALL
SELECT 'job_skills', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.job_skills`
UNION ALL
SELECT 'salaries', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.salaries`
UNION ALL
SELECT 'industries', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.industries`
UNION ALL
SELECT 'skills', COUNT(*) FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.skills`
ORDER BY filas DESC;

-- Resultado obtenido (15 ago 2026):
-- job_skills        213.768
-- job_industries     164.808
-- postings           123.849
-- benefits            67.943
-- salaries            40.785
-- employee_counts     35.787
-- companies           24.473
-- industries             422
-- skills                  36
--
-- Hallazgo relevante: solo el 33% de las ofertas (40.785/123.849) tiene
-- información salarial -> confirma la decisión de no centrar el TFM en
-- predicción de salario, tomada por el alto porcentaje de nulos.

-- --------------------------------------------------------------
-- 2. Caso documentado: diagnóstico de valores nulos en industries.industry_name
-- Objetivo: distinguir un fallo de carga de un hueco real en el dato origen.
-- --------------------------------------------------------------

-- 2.1 Comprobación puntual sobre filas conocidas del archivo fuente
SELECT *
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.industries`
WHERE industry_id IN (1, 6, 431);

-- 2.2 Cuantificación del alcance del problema
SELECT
  COUNT(*) AS total_filas,
  COUNTIF(industry_name IS NULL) AS filas_sin_nombre
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.industries`;
-- Resultado: 422 filas totales, 34 sin nombre (8%)

-- 2.3 Identificación de los registros afectados
SELECT industry_id
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.industries`
WHERE industry_name IS NULL
ORDER BY industry_id;

-- Conclusión: verificado contra el CSV original, el campo viene vacío de
-- origen (ej. línea "431,"), no es un error de carga de BigQuery.
-- Se documenta como ejemplo real de calidad de datos de un dataset de
-- producción (no sintético). Se trata con COALESCE en la vista maestra
-- (ver 03_vista_maestra.sql).

-- --------------------------------------------------------------
-- 3. Caso documentado: cabecera no detectada al cargar skills.csv
-- Objetivo: dejar constancia de una limitación real de BigQuery y su
-- corrección con DDL (ALTER TABLE), sin necesidad de recargar el archivo.
-- --------------------------------------------------------------

-- 3.1 Contexto del problema:
-- Al cargar skills.csv con "Detección automática", BigQuery no distinguió
-- la fila de encabezado de las filas de datos (ambas columnas son STRING,
-- así que el detector no encontró ninguna diferencia de tipo que le
-- permitiera identificar la primera fila como cabecera). Resultado: la
-- tabla incluía "skill_abr"/"skill_name" como una fila de datos más, y
-- las columnas quedaron nombradas genéricamente (string_field_0/1).
--
-- Forzar "Encabezado: filas que se omiten = 1" al recargar resolvió la
-- fila fantasma, pero como esa fila se descarta sin leerla, las columnas
-- se quedaron con el nombre genérico igualmente. Solución final: renombrar
-- las columnas directamente por SQL (DDL), sin volver a cargar el archivo.

ALTER TABLE `tfm-mercado-laboral-datos.mercado_laboral_datos.skills`
RENAME COLUMN string_field_0 TO skill_abr;

ALTER TABLE `tfm-mercado-laboral-datos.mercado_laboral_datos.skills`
RENAME COLUMN string_field_1 TO skill_name;

-- Verificación final:
SELECT * FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.skills`;
-- Resultado: 36 filas limpias, columnas skill_abr / skill_name correctas.

-- Hallazgo relevante para la memoria: las 36 "skills" del dataset son
-- categorías funcionales amplias (Information Technology, Engineering,
-- Sales...), NO herramientas técnicas concretas (no aparece "Python",
-- "SQL", "Power BI", etc.). Esto confirma que la Fase 3 (Text Mining
-- sobre las descripciones) es necesaria y no redundante con esta tabla.

-- --------------------------------------------------------------
-- 4. Verificación de integridad: duplicados en el origen
-- --------------------------------------------------------------
SELECT COUNT(*) AS total_filas, COUNT(DISTINCT job_id) AS job_ids_distintos
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.postings`;
-- Resultado: 123.849 = 123.849 -> sin duplicados en el origen.

-- --------------------------------------------------------------
-- 5. Hallazgo: alcance temporal real del dataset
-- --------------------------------------------------------------
SELECT
  MIN(DATE(TIMESTAMP_MILLIS(SAFE_CAST(listed_time AS INT64)))) AS fecha_min_total,
  MAX(DATE(TIMESTAMP_MILLIS(SAFE_CAST(listed_time AS INT64)))) AS fecha_max_total,
  COUNT(*) AS total_ofertas
FROM `tfm-mercado-laboral-datos.mercado_laboral_datos.postings`;
-- Resultado: TODO el dataset (123.849 filas) va del 2024-03-24 al 2024-04-20
-- (4 semanas), no de 2023 a 2024 como sugiere el nombre del dataset.
-- Es una fotografía puntual de ofertas activas, no un histórico continuo.
-- IMPORTANTE para la Fase 2: el análisis de "evolución temporal de
-- publicaciones" debe plantearse a escala diaria/semanal dentro de esta
-- ventana de 4 semanas, no como tendencia interanual.
