import boto3
import os
import io
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

def get_s3_client():
    """Connexion à AWS"""
    return boto3.client('s3')

def read_s3_csv(file_key, separator=';'):

    """Lecture d'un fichier depuis S3 et stockage dans un tableau Python"""

    s3 = get_s3_client()
    bucket = "projet-accidents-jedha"
    response = s3.get_object(Bucket=bucket, Key=file_key)

    df = pd.read_csv(io.BytesIO(response['Body'].read()), sep=separator) #conversion en DataFrame

    return df


def upload_to_s3(df, file_name, folder="silver"):

    """Étape 2 : Envoyer le tableau nettoyé vers S3"""

    s3 = get_s3_client()
    bucket = "projet-accidents-jedha"

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    
    target_key = f"{folder}/{file_name}"
    
    s3.put_object(Bucket=bucket, Key=target_key, Body=csv_buffer.getvalue())
    print(f"{target_key} est sur S3 !")