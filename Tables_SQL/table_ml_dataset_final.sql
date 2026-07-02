-- ============================================================
--  TABLE ULTIME ML — Jointure de toutes les views
--  Clé principale : Num_Acc (accident) + id_usager (victime)
-- ============================================================

-- ============================================================
--  TABLE ULTIME ML — Matérialisation physique pour performance
--  Clé principale : Num_Acc (accident) + id_usager (victime)
-- ============================================================

-- 2. Création de la table physique (Materialisation)
DROP TABLE IF EXISTS public.ml_dataset_final CASCADE;
CREATE TABLE public.ml_dataset_final AS
SELECT
    -- ── IDENTIFIANTS ────────────────────────────────────────
    u."Num_Acc",
    u.id_usager,
    u.id_vehicule,
    -- ── CIBLE ML ────────────────────────────────────────────
    u.gravite,                          
    u.graviter_blessure_label,          
    CASE
        WHEN u.gravite = 2 THEN 1
        ELSE 0
    END AS gravite_binaire,             -- ← variable cible binaire (Mort)

    -- ── USAGER ──────────────────────────────────────────────
    u.sexe,
    u.sexe_label,
    u.annee_naissance,
    u.age_victime_jour,
    u.tranche_age,
    u.categorie_usager,
    u.categorie_usager_label,
    u.motif_trajet,
    u.motif_trajet_label,
    u.equipement_secu1,
    u.equipement_secu_1_label,
    u.equipement_secu2,
    u.equipement_secu_2_label,
    u.equipement_secu3,
    u.equipement_secu_3_label,
    u.localisation_pieton,
    u.localisation_pieton_label,
    u.action_pieton,
    u.action_pieton_label,

    -- ── VÉHICULE ────────────────────────────────────────────
    v.categorie_vehicule,
    v.categorie_vehicule_label,
    v.motorisation,
    v.motorisation_label,
    v.obstacle_fixe,
    v.obstacle_fixe_label,
    v.obstacle_mobile,
    v.obstacle_mobile_label,

    -- ── CARACTÉRISTIQUES ACCIDENT ───────────────────────────
    c.date,
    c.annee_source,
    c.tranche_horaire_label,
    c.departement,
    c.label_departement,
    c.label_region,
    c.commune,
    c.lat,
    c.long,
    c.luminosite,
    c.luminosite_label,
    c.agglomeration,
    c.agglomeration_label,
    c.intersection,
    c.intersection_label,
    c.meteo,
    c.meteo_label,
    c.type_collision,
    c.type_collision_label,
    c.vacances_scolaires_flag,

    -- ── LIEUX / INFRASTRUCTURE ──────────────────────────────
    l.categorie_route,
    l.categorie_route_label,
    l.regime_circulation,
    l.nb_voies,
    l.profil_route,
    l.etat_surface,
    l.etat_surface_label,
    l.infrastructure,
    l.infrastucture_label,
    l.situation_accident,
    l.vitesse_max_autorisee

FROM public.view_usager u
LEFT JOIN public.view_vehicules v
    ON  v."Num_Acc"    = u."Num_Acc"
    AND v.id_vehicule  = u.id_vehicule
    AND v.annee_source = u.annee_source
LEFT JOIN public.view_caract c
    ON  c."Num_Acc"    = u."Num_Acc"
    AND c.annee_source = u.annee_source
LEFT JOIN public.view_lieux l
    ON  l."Num_Acc"    = u."Num_Acc"
    AND l.annee_source = u.annee_source
ORDER BY u."Num_Acc", u.id_usager;

-- 3. Ajout des Index pour booster les performances de lecture Python
CREATE INDEX idx_ml_num_acc    ON public.ml_dataset_final ("Num_Acc");
CREATE INDEX idx_ml_gravite    ON public.ml_dataset_final (gravite_binaire);
CREATE INDEX idx_ml_annee      ON public.ml_dataset_final (annee_source);
CREATE INDEX idx_ml_vacances   ON public.ml_dataset_final (vacances_scolaires_flag);