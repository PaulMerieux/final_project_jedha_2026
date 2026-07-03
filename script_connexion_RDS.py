import os
import io
import boto3
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from dotenv import load_dotenv

#Chargement des variables d'environnement
load_dotenv()
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "eu-west-3")
BUCKET_NAME = "projet-accidents-jedha"
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME")

s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=AWS_REGION
)

connection_url = f"postgresql+pg8000://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_url)

#Définition des fichiers cleaned
fichiers_a_pousser = {
    'silver/caracteristiques_cleaned.csv': 'fact_caracteristiques',
    'silver/usagers_cleaned.csv': 'dim_usagers',
    'silver/vehicules_cleaned.csv': 'dim_vehicules',
    'silver/lieux_cleaned.csv': 'fact_lieux',
    'silver/referentiel_vacances.csv': 'dim_vac_scolaire'
}

def executer_scripts_sql(engine, dossier_sql="Tables_SQL"):

    """Lit et exécute tous les fichiers .sql du dossier tables_SQL."""
    
    if not os.path.exists(dossier_sql):
        print(f"Dossier '{dossier_sql}' non trouvé. Pas de vues créées.")
        return
    fichiers = sorted([f for f in os.listdir(dossier_sql) if f.endswith('.sql')])
    
    try:
        with engine.begin() as conn:
            for nom_fichier in fichiers:
                chemin = os.path.join(dossier_sql, nom_fichier)

                with open(chemin, 'r', encoding='utf-8') as f:
                    sql = f.read()

                print(f"Exécution du script : {nom_fichier}...")
                conn.execute(text(sql))
            print("Toutes les vues ont été recréées.")
    except Exception as e:
        print(f"Erreur lors de la création des vues : {e}")

def run():
    print(f"Début de l'automatisation vers : {DB_HOST}")
    
    try:
        for s3_key, table_name in fichiers_a_pousser.items():
            print(f"\n--- Traitement de la table : {table_name} ---")
            try:
                response = s3_client.get_object(Bucket=BUCKET_NAME, Key=s3_key)
                df = pd.read_csv(io.BytesIO(response['Body'].read()), sep=',', low_memory=False)
                print(f"Données S3 récupérées ({len(df)} lignes).")
                
                #Tentative de TRUNCATE + APPEND si le APPEND échoue (ex: nouvelles colonnes), on utilise CASCADE pour tout supp puis on recrée tous  
                try:
                    with engine.begin() as conn:
                        conn.execute(text(f'TRUNCATE TABLE "{table_name}" CASCADE;'))
                    
                    df.to_sql(table_name, engine, if_exists='append', index=False, method='multi', chunksize=3000)
                    print(f"Mise à jour en mode APPEND.")

                except Exception as e_append:                  
                    with engine.begin() as conn:
                        print(f"Suppression forcée de la table {table_name} (et de ses vues)...")
                        conn.execute(text(f'DROP TABLE IF EXISTS "{table_name}" CASCADE;'))
                    
                    #On recrée la table avec la nouvelle structure
                    df.to_sql(table_name, engine, if_exists='replace', index=False, method='multi', chunksize=3000)
                    print(f"Table {table_name} recréée proprement.")

            except Exception as e:
                print(f"Erreur sur {table_name} : {e}")
                continue 

        print("\n--- Reconstruction des Vues SQL ---")
        executer_scripts_sql(engine)

        print(f"\n Pipeline terminé et Power BI est à jour.")

    except Exception as e:
        print(f"Erreur inattendue dans le pipeline : {e}")

if __name__ == "__main__":
    run()