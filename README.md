[README.md](https://github.com/user-attachments/files/31105182/README.md)
# tfm-mercado-laboral-datos
TFM - Análisis del Mercado Laboral en Datos y Analytics (UCM)
# Análisis del Mercado Laboral en Datos y Analytics

Trabajo Fin de Máster — Máster de Formación Permanente en Data Science, Big Data & Business Analytics (UCM, modalidad Online).

**Alumno:** Christian Escribano Castro
**Tutores:** Carlos Ortega y Santiago Mota

## Objetivo del proyecto

Construir un sistema de inteligencia del mercado laboral en el sector de datos y analytics que identifique arquetipos de perfil profesional, las skills que más determinan cada tipo de rol, y una herramienta que, dado el perfil de un candidato, recomiende qué roles son más accesibles y qué skills debería priorizar.

*Nota: el proyecto no incluye predicción salarial, por el alto porcentaje de valores ausentes en ese campo del dataset original (ver memoria, apartado 1).*

## Dataset

**LinkedIn Job Postings 2023-2024** — [Kaggle, usuario arshkon](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings). 123.849 ofertas de empleo, 9 tablas relacionadas. Licencia CC BY-SA 4.0 (ver [`docs/licencia_datos.md`](docs/licencia_datos.md)).

## Estructura del repositorio

| Carpeta | Contenido | Fase / Módulo del máster |
|---|---|---|
| [`sql/`](sql/) | Exploración, calidad de datos, categorización de roles, vista analítica maestra | Fase 1 · Bases de Datos SQL |
| `notebooks/` | Cuadernos de Google Colab (EDA, Text Mining, Machine Learning, productivización) | Fases 2, 3, 4 y 6 · Python, Estadística, Text Mining, ML, Visualización |
| `dashboard/` | Dashboard ejecutivo de Power BI | Fase 5 · Business Intelligence |
| `modelos/` | Modelo Random Forest serializado (`.pkl`) | Fase 6 · Productivización |
| `docs/` | Notas complementarias (licencia de datos, etc.) | — |

## Entorno técnico

- **SQL:** Google BigQuery (Sandbox, nivel gratuito)
- **Python / análisis:** Google Colab
- **Visualización / BI:** Microsoft Power BI Desktop
- **Dataset:** Kaggle (arshkon/linkedin-job-postings)

## Estado del proyecto

- [x] Fase 1 · Modelado y consultas SQL en BigQuery
- [x] Fase 2 · Análisis exploratorio y estadístico (Python)
- [ ] Fase 3 · Text Mining de skills
- [ ] Fase 4 · Machine Learning (clustering + clasificación)
- [ ] Fase 5 · Dashboard en Power BI
- [ ] Fase 6 · Productivización del modelo

## Memoria y vídeo

La memoria técnica completa y el vídeo de presentación se entregan junto con este repositorio en la plataforma de la UCM.
