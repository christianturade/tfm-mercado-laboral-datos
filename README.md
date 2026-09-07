# tfm-mercado-laboral-datos

TFM - Análisis del Mercado Laboral en Datos y Analytics (UCM)

# 📊 Análisis del Mercado Laboral en Datos y Analytics

Trabajo Fin de Máster, Máster de Formación Permanente en Data Science, Big Data & Business Analytics (UCM, modalidad Online).

**Alumno:** Christian Escribano Castro
**Tutores:** Carlos Ortega y Santiago Mota

## Objetivo del proyecto

Construir un sistema de inteligencia del mercado laboral en el sector de datos y analytics que identifique arquetipos de perfil profesional, las skills que más determinan cada tipo de rol, y una herramienta que, dado el perfil de un candidato, recomiende qué roles son más accesibles y qué skills debería priorizar.

## 🚀 Aplicación web: recomendador de rol

La función de recomendación de la Fase 6 está desplegada como aplicación web pública:

https://tfm-mercado-laboral-datos-x34ttebhwczxtksger98st.streamlit.app/

A partir de un perfil (industria, modalidad, experiencia y skills) devuelve el rol más accesible, el ranking completo de los 7 roles y las skills que faltan para acercarse al mejor puntuado.

## Dataset

LinkedIn Job Postings 2023-2024, de Kaggle (usuario arshkon): 123.849 ofertas de empleo en 9 tablas relacionadas. Licencia CC BY-SA 4.0 (ver [`docs/licencia_datos.md`](docs/licencia_datos.md)).

## Estructura del repositorio

| Carpeta | Contenido | Fase / módulo del máster |
|---|---|---|
| [`sql/`](sql/) | Exploración, calidad de datos, categorización de roles y vista analítica maestra | Fase 1 · Bases de Datos SQL |
| [`notebooks/`](notebooks/) | Cuadernos de Google Colab: EDA, estadística, Text Mining, Machine Learning y productivización | Fases 2, 3, 4 y 6 |
| [`tableau/`](tableau/) | Libro de trabajo del dashboard | Fase 5 · Business Intelligence |
| [`modelos/`](modelos) | Modelo Random Forest y vectorizador serializados (`.pkl`) | Fase 6 · Productivización |
| [`app/`](app/) | Código de la aplicación Streamlit del recomendador de rol | Fase 6 · Productivización |
| [`docs/`](docs/) | Notas complementarias (licencia de datos, etc.) | — |

## Entorno técnico

SQL en Google BigQuery (Sandbox, nivel gratuito). Análisis en Python sobre Google Colab. Visualización y BI con Tableau Public. Aplicación web con Streamlit, desplegada en Streamlit Community Cloud. Dataset de Kaggle (arshkon/linkedin-job-postings).

## Estado del proyecto

Las seis fases están completas: modelado y consultas SQL en BigQuery, análisis exploratorio y estadístico en Python, Text Mining de skills, Machine Learning (clustering y clasificación), dashboard interactivo en Tableau, y productivización del modelo con la función `recomendar_rol()` y la app desplegada.

## Memoria y vídeo

La memoria técnica completa y el vídeo de presentación se entregan junto con este repositorio en la plataforma de la UCM.
