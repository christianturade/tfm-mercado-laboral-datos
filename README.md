[README_actualizado.md](https://github.com/user-attachments/files/31596079/README_actualizado.md)
# tfm-mercado-laboral-datos
TFM - Análisis del Mercado Laboral en Datos y Analytics (UCM)
# Análisis del Mercado Laboral en Datos y Analytics

Trabajo Fin de Máster — Máster de Formación Permanente en Data Science, Big Data & Business Analytics (UCM, modalidad Online).

**Alumno:** Christian Escribano Castro
**Tutores:** Carlos Ortega y Santiago Mota

## Objetivo del proyecto

Construir un sistema de inteligencia del mercado laboral en el sector de datos y analytics que identifique arquetipos de perfil profesional, las skills que más determinan cada tipo de rol, y una herramienta que, dado el perfil de un candidato, recomiende qué roles son más accesibles y qué skills debería priorizar.

## Aplicación web · Recomendador de rol

La función de recomendación de la Fase 6 está desplegada como aplicación web pública, sin necesidad de ejecutar código:

**➡️ https://tfm-mercado-laboral-datos-x34ttebhwczxtksger98st.streamlit.app/**

Introduce un perfil (industria, modalidad, experiencia y skills) y devuelve el rol más accesible junto con el ranking completo de los 7 roles y las skills que faltan para acercarse al mejor puntuado.

## Dataset

**LinkedIn Job Postings 2023-2024** — [Kaggle, usuario arshkon](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings). 123.849 ofertas de empleo, 9 tablas relacionadas. Licencia CC BY-SA 4.0 (ver [`docs/licencia_datos.md`](docs/licencia_datos.md)).

## Estructura del repositorio

| Carpeta | Contenido | Fase / Módulo del máster |
|---|---|---|
| [`sql/`](sql/) | Exploración, calidad de datos, categorización de roles, vista analítica maestra | Fase 1 · Bases de Datos SQL |
| [`notebooks/`](notebooks/) | Cuadernos de Google Colab (EDA, Text Mining, Machine Learning, productivización) | Fases 2, 3, 4 y 6 · Python, Estadística, Text Mining, ML, Visualización |
| [`tableau/`](tableau/) | Dashboard ejecutivo de Tableau | Fase 5 · Business Intelligence |
| [`modelos/`](modelos) | Modelo Random Forest serializado (`.pkl`) | Fase 6 · Productivización |
| [`app/`](app/) | Aplicación Streamlit del recomendador de rol (código + modelo servido) | Fase 6 · Productivización (app desplegada) |
| [`docs/`](docs/) | Notas complementarias (licencia de datos, etc.) | — |

## Entorno técnico

- **SQL:** Google BigQuery (Sandbox, nivel gratuito)
- **Python / análisis:** Google Colab
- **Visualización / BI:** Tableau Public
- **Aplicación web:** Streamlit, desplegada en Streamlit Community Cloud
- **Dataset:** Kaggle (arshkon/linkedin-job-postings)

## Estado del proyecto

- [x] Fase 1 · Modelado y consultas SQL en BigQuery
- [x] Fase 2 · Análisis exploratorio y estadístico (Python)
- [x] Fase 3 · Text Mining de skills
- [x] Fase 4 · Machine Learning (clustering + clasificación)
- [x] Fase 5 · Dashboard interactivo en Tableau
- [x] Fase 6 · Productivización del modelo (función `recomendar_rol()` + app web desplegada)

## Memoria y vídeo

La memoria técnica completa y el vídeo de presentación se entregan junto con este repositorio en la plataforma de la UCM.
