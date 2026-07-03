import asyncio
import aiohttp
import boto3
import requests
import os
from dotenv import load_dotenv

# --- CHARGEMENT DES VARIABLES D'ENVIRONNEMENT ---
load_dotenv() # Cherche le fichier .env et charge les clés AWS

# --- CONFIGURATION ---
DATASET_ID = "53698f4ca3a729239d2036df"
ANNEES_VOULUES = ["2021", "2022", "2023", "2024"]
S3_BUCKET = "projet-accidents-jedha"
HEADERS = {'User-Agent': 'Mozilla/5.0'}

async def download_and_upload(session, url, file_name):
    try:
        async with session.get(url, timeout=300) as response:
            if response.status == 200:
                print(f"Transfert en cours : {file_name}...")
                content = await response.read()
                
                # Boto3 utilise automatiquement les variables chargées par load_dotenv()
                # verifié que le dossier eiste bien.
                # Ici le dossier à changé !!!
                s3 = boto3.client('s3')
                s3.put_object(Bucket=S3_BUCKET, Key=f"bronze/BAAC/{file_name}", Body=content)
                
                print(f"Réussi : {file_name}")
            else:
                print(f"Échec {response.status} pour {file_name}")
    except Exception as e:
        print(f"Erreur sur {file_name} : {str(e)}")

async def run():
    api_url = f"https://www.data.gouv.fr/api/1/datasets/{DATASET_ID}/"
    r = requests.get(api_url, headers=HEADERS)
    r.raise_for_status() # S'assure que l'API a répondu
    resources = r.json().get('resources', [])

    tasks = []
    async with aiohttp.ClientSession(headers=HEADERS) as session:
        for res in resources:
            title = res.get('title', '')
            url = res.get('url')
            
            # Filtre : Année ET CSV (attention, certains titres sur data.gouv sont en majuscules)
            if any(annee in title for annee in ANNEES_VOULUES) and "csv" in res.get('format', '').lower():
                clean_name = title.replace(" ", "_").replace("(", "").replace(")", "")
                if not clean_name.lower().endswith(".csv"): clean_name += ".csv"
                tasks.append(download_and_upload(session, url, clean_name))

        if tasks:
            print(f"Lancement de {len(tasks)} téléchargements...")
            await asyncio.gather(*tasks)
        else:
            print("Aucun fichier trouvé. Vérifie les années ou l'ID.")

# --- L'ÉTAPE CRUCIALE POUR LANCER LE CODE ---

if __name__ == "__main__":
    asyncio.run(run())