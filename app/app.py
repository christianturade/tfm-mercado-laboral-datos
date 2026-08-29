"""
Recomendador de Rol y Skills — Análisis del Mercado Laboral en Datos y Analytics
TFM · Máster de Formación Permanente en Data Science, Big Data & Business Analytics (UCM)
Autor: Christian Escribano Castro

Esta app productiviza el modelo entrenado en la Fase 6 del TFM (notebook
`06_productivizacion.ipynb`): dado el perfil de una persona (industria de
interés, modalidad de trabajo, nivel de experiencia y skills que ya tiene),
devuelve el ranking de los 7 roles del sector ordenados por probabilidad y
las skills que le faltan para acercarse al rol mejor puntuado.

El modelo (Random Forest) y el DictVectorizer que lo acompaña se cargan tal
cual se serializaron en el notebook, sin reentrenar nada aquí — esta app es
solo la capa de presentación sobre un modelo ya validado.
"""

import json
from pathlib import Path

import joblib
import plotly.graph_objects as go
import streamlit as st

# Rutas relativas a la ubicación de este script (no al directorio de
# ejecución), para que funcione igual en local y en Streamlit Cloud.
MODELOS_DIR = Path(__file__).parent / "modelos"

# --------------------------------------------------------------------------
# Configuración de página y paleta visual (misma identidad que la memoria,
# el dashboard de Tableau y las presentaciones del TFM)
# --------------------------------------------------------------------------
st.set_page_config(
    page_title="Recomendador de Rol · TFM Mercado Laboral en Datos y Analytics",
    page_icon="🎯",
    layout="wide",
)

PRIMARY = "#1F3D2B"       # verde bosque — cabeceras
SECONDARY = "#4C7A5A"     # verde musgo — acentos secundarios
SECONDARY_LIGHT = "#E7EFE9"
ACCENT = "#C9861F"        # ámbar — cifras destacadas
TEXT = "#2B332E"
MUTED = "#6B7770"
CARD_BG = "#F6F8F6"

st.markdown(f"""
<style>
    .stApp {{ background-color: #FFFFFF; }}
    h1, h2, h3 {{ color: {PRIMARY}; font-family: Arial, sans-serif; }}
    p, div, span, label {{ font-family: Arial, sans-serif; }}
    .kicker {{
        color: {ACCENT}; font-weight: 700; font-size: 0.8rem;
        letter-spacing: 2px; text-transform: uppercase;
    }}
    .result-card {{
        background-color: {CARD_BG}; border-radius: 10px;
        padding: 1.1rem 1.3rem; margin-bottom: 0.6rem;
    }}
    .top-role-card {{
        background-color: {PRIMARY}; color: white; border-radius: 10px;
        padding: 1.4rem 1.6rem; margin-bottom: 1rem;
    }}
    .skill-chip {{
        display: inline-block; background-color: {SECONDARY_LIGHT};
        color: {PRIMARY}; border-radius: 20px; padding: 0.3rem 0.9rem;
        margin: 0.2rem 0.3rem 0.2rem 0; font-size: 0.9rem; font-weight: 600;
    }}
    .footer-note {{ color: {MUTED}; font-size: 0.8rem; }}
    div[data-testid="stMetricValue"] {{ color: {ACCENT}; }}
    button[kind="primary"] {{
        background-color: {PRIMARY} !important; border-color: {PRIMARY} !important;
    }}
    button[kind="primary"]:hover {{
        background-color: {SECONDARY} !important; border-color: {SECONDARY} !important;
    }}
</style>
""", unsafe_allow_html=True)

# --------------------------------------------------------------------------
# Carga del modelo, el vectorizador y la tabla de skills por rol
# (cacheada: se carga una sola vez por sesión de servidor, no en cada clic)
# --------------------------------------------------------------------------
@st.cache_resource
def cargar_artefactos():
    modelo = joblib.load(MODELOS_DIR / "modelo_rol.pkl")
    vectorizador = joblib.load(MODELOS_DIR / "vectorizador_rol.pkl")
    with open(MODELOS_DIR / "skills_por_rol.json", encoding="utf-8") as f:
        skills_por_rol = json.load(f)
    return modelo, vectorizador, skills_por_rol


modelo_final, vectorizador, top_skills_por_rol = cargar_artefactos()

# Listas de valores válidos — exactamente las categorías que vio el
# vectorizador al entrenar (Fase 6), para que ninguna combinación del
# formulario caiga fuera de lo que el modelo sabe interpretar.
INDUSTRIAS = sorted([
    "Advertising Services", "Banking", "Biotechnology Research",
    "Business Consulting and Services", "Defense and Space Manufacturing",
    "Entertainment Providers", "Financial Services", "Government Administration",
    "Higher Education", "Hospitals and Health Care", "IT Services and IT Consulting",
    "Information Services", "Information Technology & Services", "Insurance",
    "Manufacturing", "Otras", "Pharmaceutical Manufacturing", "Retail",
    "Software Development", "Staffing and Recruiting", "Technology",
    "Telecommunications",
])
MODALIDADES = ["No especificado", "Remoto"]
NIVELES_EXPERIENCIA = [
    "Internship", "Entry level", "Associate", "Mid-Senior level",
    "Director", "Executive", "No especificado",
]
SKILLS_DISPONIBLES = sorted([
    "Python", "SQL", "R", "Java", "Scala", "VBA", "Excel", "Power BI", "Tableau",
    "Looker", "Qlik", "SAP", "Salesforce", "Alteryx", "AWS", "Azure", "Google Cloud",
    "Snowflake", "Redshift", "BigQuery", "Databricks", "Spark", "Hadoop", "Kafka",
    "Airflow", "ETL", "MySQL", "PostgreSQL", "MongoDB", "NoSQL", "Machine Learning",
    "Deep Learning", "TensorFlow", "PyTorch", "Scikit-learn", "Pandas", "NumPy",
    "Git", "Docker", "Kubernetes", "Jira", "Agile", "Scrum", "DAX", "C++",
])

COLOR_ROLES = {
    "Business Analyst": "#EB9C3E", "Data Analyst": "#D6604D",
    "Data Engineer": "#4C9F5B", "Data Scientist": "#E0BE3C",
    "BI Analyst / Developer": "#4472A8", "Machine Learning Engineer": "#A569BD",
    "Data Architect": "#4FA8A0",
}


def recomendar_rol(industria_principal, modalidad_remoto, formatted_experience_level, skills_actuales):
    """
    Réplica exacta de la función construida en `06_productivizacion.ipynb`:
    vectoriza el perfil, pide la probabilidad de cada rol al Random Forest,
    y calcula qué skills del rol mejor puntuado le faltan a la persona.
    """
    num_skills = len(skills_actuales)
    perfil = {
        "industria_principal": industria_principal,
        "modalidad_remoto": modalidad_remoto,
        "formatted_experience_level": formatted_experience_level,
        "num_skills": num_skills,
    }
    x_perfil = vectorizador.transform([perfil])
    probabilidades = modelo_final.predict_proba(x_perfil)[0]
    ranking = sorted(zip(modelo_final.classes_, probabilidades), key=lambda x: x[1], reverse=True)

    rol_top = ranking[0][0]
    skills_del_rol = top_skills_por_rol[rol_top]
    skills_que_faltan = [s for s in skills_del_rol if s not in skills_actuales]

    return ranking, rol_top, skills_que_faltan


# --------------------------------------------------------------------------
# Cabecera
# --------------------------------------------------------------------------
st.markdown('<div class="kicker">FASE 6 · PRODUCTIVIZACIÓN DEL MODELO</div>', unsafe_allow_html=True)
st.title("¿Qué rol se ajusta a tu perfil?")
st.write(
    "Introduce tu perfil y la app te dirá qué rol del sector de datos y analytics "
    "es más accesible para ti ahora mismo, y qué skills concretas te faltan para "
    "acercarte más a él. El modelo (Random Forest) se entrenó sobre 2.163 ofertas "
    "reales de LinkedIn — ver el resto del análisis en la "
    "[memoria completa](https://github.com/christianturade/tfm-mercado-laboral-datos) "
    "y en el [dashboard interactivo](https://public.tableau.com/app/profile/christian.escribano.castro/viz/TFM-MercadoLaboralDatosyAnalytics/Dashboardprincipal)."
)
st.divider()

# --------------------------------------------------------------------------
# Formulario de perfil
# --------------------------------------------------------------------------
col_form, col_resultado = st.columns([1, 1.4], gap="large")

with col_form:
    st.subheader("Tu perfil")
    industria = st.selectbox("Industria de interés", INDUSTRIAS, index=INDUSTRIAS.index("IT Services and IT Consulting"))
    modalidad = st.selectbox("Modalidad de trabajo", MODALIDADES)
    experiencia = st.selectbox("Nivel de experiencia", NIVELES_EXPERIENCIA, index=1)
    skills_actuales = st.multiselect(
        "Skills que ya tienes",
        SKILLS_DISPONIBLES,
        help="Selecciona todas las herramientas y tecnologías que ya dominas. "
             "El número de skills es, según la Fase 4 del TFM, la variable que más "
             "influye en la predicción del rol.",
    )
    calcular = st.button("Recomendar rol", type="primary", use_container_width=True)

# --------------------------------------------------------------------------
# Resultado
# --------------------------------------------------------------------------
with col_resultado:
    st.subheader("Resultado")

    if not calcular:
        st.info("Completa tu perfil a la izquierda y pulsa **Recomendar rol** para ver el resultado.")
    else:
        ranking, rol_top, skills_que_faltan = recomendar_rol(industria, modalidad, experiencia, skills_actuales)
        prob_top = ranking[0][1]

        st.markdown(f"""
        <div class="top-role-card">
            <div style="font-size:0.85rem;opacity:0.8;letter-spacing:1px;">ROL MÁS ACCESIBLE</div>
            <div style="font-size:2.1rem;font-weight:800;margin:0.2rem 0;">{rol_top}</div>
            <div style="font-size:1rem;opacity:0.9;">probabilidad estimada: {prob_top * 100:.1f}%</div>
        </div>
        """, unsafe_allow_html=True)

        # Ranking completo como gráfico de barras horizontales
        roles = [r for r, _ in ranking]
        probs = [p * 100 for _, p in ranking]
        colores = [COLOR_ROLES.get(r, SECONDARY) for r in roles]

        fig = go.Figure(go.Bar(
            x=probs[::-1], y=roles[::-1], orientation="h",
            marker_color=colores[::-1],
            text=[f"{p:.1f}%" for p in probs[::-1]],
            textposition="outside",
        ))
        fig.update_layout(
            title="Ranking completo de roles por probabilidad",
            xaxis_title="Probabilidad (%)", xaxis_range=[0, max(probs) * 1.2],
            plot_bgcolor="#FFFFFF", paper_bgcolor="#FFFFFF",
            font=dict(color=TEXT, size=13), height=320,
            margin=dict(l=10, r=10, t=40, b=10),
        )
        st.plotly_chart(fig, use_container_width=True)

        # Skills a priorizar
        st.markdown(f"**Para acercarte a {rol_top}, prioriza estas skills:**")
        if skills_que_faltan:
            chips = "".join(f'<span class="skill-chip">{s}</span>' for s in skills_que_faltan[:5])
            st.markdown(chips, unsafe_allow_html=True)
        else:
            st.success("Ya tienes todas las skills más demandadas para este rol.")

st.divider()
st.markdown(
    '<div class="footer-note">Christian Escribano Castro · TFM Mercado Laboral en Datos y Analytics · '
    'Modelo: Random Forest (100 árboles) entrenado sobre 2.163 ofertas reales de LinkedIn (2023-2024)</div>',
    unsafe_allow_html=True,
)
