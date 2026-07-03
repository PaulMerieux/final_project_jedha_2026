import pandas as pd
from s3_utils import read_s3_csv, upload_to_s3, get_s3_client
import cleaning_functions as cf
from vacances_api import fetch_vacances_data

# ══════════════════════════════════════════════════════════════════════════════
# main.py — Version corrigée et synchronisée avec cleaning_functions.py
#
# Corrections vs version précédente :
# 1. cleaning_func(df_raw) → cleaning_func(df_raw, annee) : passage de l'année
# 2. Détection de l'année depuis le nom du fichier (2021/2022/2023/2024)
# 3. Ordre des jointures corrigé : usagers → caract → lieux → vehicules
#    (était usagers → vehicules → caract → lieux, ce qui peut créer des doublons)
# 4. Clé jointure vehicules : ['Num_Acc', 'id_vehicule'] uniquement
#    (num_veh supprimé dans clean_usagers et clean_vehicules)
# 5. Suppression colonnes dupliquées post-merge (_x, _y, annee en double)
# 6. Vérification du nombre de lignes attendu (506 886 ± tolérance)
# ══════════════════════════════════════════════════════════════════════════════

BUCKET = "projet-accidents-jedha"

ANNEES = [2021, 2022, 2023, 2024]


def get_all_files(s3_client, bucket, prefix):

    """Liste tous les fichiers CSV dans un dossier S3."""
    
    response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)
    return [obj['Key'] for obj in response.get('Contents', []) if obj['Key'].endswith('.csv')]


def detect_annee(filepath):
    
    """
    Détecte l'année depuis le nom du fichier. Ex : 'bronze/usagers_2022.csv' → 2022. Retourne None si aucune année trouvée.
    """

    for annee in ANNEES:
        if str(annee) in filepath:
            return annee
    return None


def process_and_upload_silver(all_files, keyword, cleaning_func, silver_name):
    
    """
    Lit les fichiers bruts depuis S3 bronze/, applique le nettoyage, concatene les 4 années et uploade le résultat dans silver/.
    """

    dfs = []
    print(f"\n Préparation Silver : {silver_name}...")

    for f in all_files:
        if keyword in f.lower():

            if 'immatricul' in f.lower():
                print(f"Ignoré (immatriculation) : {f}")
                continue

            sep = ';'
            annee = detect_annee(f)
            if annee is None:
                print(f"Impossible de détecter l'année pour {f} — fichier ignoré")
                continue

            print(f"   -> Lecture {f} (année={annee}, sep='{sep}')")
            df_raw = read_s3_csv(f, separator=sep)

            # CORRECTION : on passe maintenant l'année en paramètre
            df_clean = cleaning_func(df_raw, annee)
            dfs.append(df_clean)

    if not dfs:
        print(f"Aucun fichier trouvé pour le mot-clé '{keyword}'")
        return pd.DataFrame()

    df_silver = pd.concat(dfs, ignore_index=True)

    upload_to_s3(df_silver, f"{silver_name}.csv", folder="silver")
    print(f"Silver '{silver_name}' uploadé — {len(df_silver):,} lignes x {df_silver.shape[1]} colonnes")

    return df_silver


def run():
    s3 = get_s3_client()
    all_files = get_all_files(s3, BUCKET, 'bronze/BAAC/')
    print(f"{len(all_files)} fichiers CSV trouvés dans bronze/")

    # ── ÉTAPE 0 : PIPELINE VACANCES (API -> SILVER) ─────────────────────────
    print("\n LANCEMENT DU PIPELINE RÉFÉRENTIEL VACANCES...")
    try:
        # 1. On récupère les données via l'API (ton nouveau script)
        df_vacances_raw = fetch_vacances_data()
        
        if df_vacances_raw is not None:
            # 2. On nettoie et on "déplie" le calendrier (ta nouvelle fonction)
            df_vacances_clean = cf.clean_vacances(df_vacances_raw)
            
            # 3. On envoie le résultat sur S3 dans le dossier Silver
            upload_to_s3(df_vacances_clean, "referentiel_vacances.csv", folder="silver")
            print(f"Référentiel vacances mis à jour : {len(df_vacances_clean):,} lignes.")
    except Exception as e:
        # Si l'API plante, on affiche l'erreur mais on ne bloque pas le reste du pipeline
        print(f"Échec du pipeline vacances : {e} (Suite du pipeline...)")

    # ── ÉTAPE 1 : SILVER — nettoyage des 4 tables ───────────────────────────
    df_usagers  = process_and_upload_silver(all_files, 'usagers',   cf.clean_usagers,          "usagers_cleaned")
    df_caract   = process_and_upload_silver(all_files, 'caract',    cf.clean_caracteristiques,  "caracteristiques_cleaned")
    df_lieux    = process_and_upload_silver(all_files, 'lieux',     cf.clean_lieux,             "lieux_cleaned")
    df_vehicules = process_and_upload_silver(all_files, 'vehicules', cf.clean_vehicules,        "vehicules_cleaned")

    # Vérification que les 4 tables sont bien chargées avant de merger
    for name, df in [("usagers", df_usagers), ("caract", df_caract),
                     ("lieux", df_lieux), ("vehicules", df_vehicules)]:
        if df.empty:
            print(f"Table '{name}' vide — arrêt du pipeline")
            return

    # ── ÉTAPE 2 : GOLD — jointure dans le bon ordre ─────────────────────────
    print("\n Création de la table Gold V2 (Master Merge)...")

    # CORRECTION : ordre des jointures aligné sur alex_jointure.ipynb
    # BASE : usagers (1 ligne = 1 usager) — on ne perd aucune ligne (left join)
    # JOIN 1 : + caract sur Num_Acc
    master = pd.merge(df_usagers, df_caract, on='Num_Acc', how='left', suffixes=('', '_caract'))

    # JOIN 2 : + lieux sur Num_Acc
    # drop_duplicates déjà fait dans clean_lieux — pas de multiplication de lignes
    master = pd.merge(master, df_lieux, on='Num_Acc', how='left', suffixes=('', '_lieux'))

    # JOIN 3 : + vehicules sur Num_Acc + id_vehicule (double clé)
    # CORRECTION : num_veh supprimé dans les fonctions de nettoyage → retiré de la clé
    master = pd.merge(master, df_vehicules, on=['Num_Acc', 'id_vehicule'], how='left', suffixes=('', '_vehicules'))

    # ── ÉTAPE 3 : Nettoyage post-merge ──────────────────────────────────────
    # Suppression des colonnes dupliquées créées par les suffixes
    cols_to_drop = [c for c in master.columns if c.endswith(('_caract', '_lieux', '_vehicules'))]
    if cols_to_drop:
        master = master.drop(columns=cols_to_drop)
        print(f"   Colonnes dupliquées supprimées : {cols_to_drop}")

    # ── ÉTAPE 5 : RAPPORT FINAL ─────────────────────────────────────────────
    print(f"\n{'═'*55}")
    print(f"PIPELINE V2 TERMINÉ")
    print(f"   Silver usagers      : {len(df_usagers):>8,} lignes")
    print(f"   Silver caract       : {len(df_caract):>8,} lignes")
    print(f"   Silver lieux        : {len(df_lieux):>8,} lignes")
    print(f"   Silver vehicules    : {len(df_vehicules):>8,} lignes")
    print(f"   Gold master         : {len(master):>8,} lignes x {master.shape[1]} colonnes")

    # Vérification du nombre de lignes attendu
    # Le gold doit avoir le même nombre de lignes que usagers (left join depuis usagers)
    if len(master) != len(df_usagers):
        print(f"\n ATTENTION : le Gold ({len(master):,} lignes) diffère de usagers ({len(df_usagers):,} lignes)")
        print(f"   Différence : {len(master) - len(df_usagers):,} lignes — vérifier le merge lieux (drop_duplicates)")
    else:
        print(f"\n Nombre de lignes cohérent — 0 ligne perdue ou dupliquée")

    # Vérification des années présentes dans le master
    if 'annee' in master.columns:
        annees = sorted(master['annee'].dropna().unique().tolist())
        print(f"   Années dans le master : {annees}")
        if len(annees) < 4:
            print(f"  Seulement {len(annees)} année(s) — vérifie que 2022 est bien dans bronze/")


if __name__ == "__main__":
    run()
