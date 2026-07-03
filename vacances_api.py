import requests
import pandas as pd 
import time
from datetime import datetime


def generer_annees_scolaires(annee_debut=2020):
    """
    Génère les années scolaires du type '2020-2021' depuis annee_debut, jusqu'à l'année scolaire en cours (incluse), en se basant sur la date du jour.
    """
    aujourd_hui = datetime.now()
    annee_courante = aujourd_hui.year

 
    if aujourd_hui.month >= 8: # Si on est après juillet, l'année scolaire en cours a démarré cette année (ex: 2026-2027)
        derniere_annee_scolaire_debut = annee_courante
    else:
        derniere_annee_scolaire_debut = annee_courante - 1

    return [f"{a}-{a+1}" for a in range(annee_debut, derniere_annee_scolaire_debut + 1)]

def fetch_vacances_data():
    """
    Cette fonction automatise la récupération du calendrier scolaire sur plusieurs années en interrogeant l'API officielle.
    """
    
    annees_a_recuperer = generer_annees_scolaires(2020)
    
    all_results = [] #pour stocker les données
    
    dataset_id = "fr-en-calendrier-scolaire"
    base_url = f"https://data.education.gouv.fr/api/explore/v2.1/catalog/datasets/{dataset_id}/records"

    print("Début de la récupération multi-années...")

    for annee in annees_a_recuperer: #¨pour chaque année
        offset = 0  # On commence à la ligne 0 pour chaque nouvelle année
        limit = 100 # On demande les données par paquets de 100 lignes
        
        print(f"Traitement de l'année scolaire : {annee}")
        
        while True:
            params = {
                "limit": limit,     # Combien de lignes on veut
                "offset": offset,   # À partir de quelle ligne on commence
                "refine": f"annee_scolaire:{annee}" # Filtre pour n'avoir QUE cette année
            }
            
            try:
                response = requests.get(base_url, params=params, timeout=10)
                
                if response.status_code != 200:
                    print(f"Erreur serveur sur l'année {annee}")
                    break
                
                data = response.json()
                batch = data.get('results', []) 
                
                # S'il n'y a plus de lignes dans cette page, c'est qu'on a fini l'année !
                if not batch:
                    break
        
                all_results.extend(batch) #On stock le paquet de 100 lignes
                
                offset += limit #On prépare la page suivante (ex: on passe de la ligne 0 à 100)
                
                time.sleep(0.1) #On attend 0.1 seconde pour ne pas brusquer le serveur
                
            except Exception as e:
                print(f"Erreur ou bug : {e}")
                break
    
    df_raw = pd.json_normalize(all_results)  # On transforme notre liste géante de résultats JSON en un DataFrame
    
    print(f"Terminé ! {len(df_raw)} lignes prêtes pour le nettoyage.")
    
    return df_raw