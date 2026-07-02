 CREATE OR REPLACE VIEW public.view_usager
 AS
 SELECT r."Num_Acc",
    r.id_usager,
    r.id_vehicule,
    r.categorie_usager,
    r.gravite,
    r.sexe,
    r.annee_naissance,
    r.motif_trajet,
    r.equipement_secu1,
    r.equipement_secu2,
    r.equipement_secu3,
    r.localisation_pieton,
    r.action_pieton,
    r.annee_source,
        CASE r.categorie_usager
            WHEN 1 THEN 'Conducteur'::text
            WHEN 2 THEN 'Passager'::text
            WHEN 3 THEN 'Piéton'::text
            ELSE 'Inconnu'::text
        END AS categorie_usager_label,
        CASE r.gravite
            WHEN 1 THEN 'Indemne'::text
            WHEN 2 THEN 'Tué'::text
            WHEN 3 THEN 'Blessé hospitalisé'::text
            WHEN 4 THEN 'Blessé léger'::text
            ELSE 'Inconnu'::text
        END AS graviter_blessure_label,
        CASE r.sexe
            WHEN 1 THEN 'Homme'::text
            WHEN 2 THEN 'Femme'::text
            ELSE 'Inconnu'::text
        END AS sexe_label,
        CASE r.motif_trajet
            WHEN 0 THEN 'Non renseigné'::text
            WHEN 1 THEN 'Domicile – travail'::text
            WHEN 2 THEN 'Domicile – école'::text
            WHEN 3 THEN 'Courses – achats'::text
            WHEN 4 THEN 'Utilisation professionnelle'::text
            WHEN 5 THEN 'Promenade – loisirs'::text
            WHEN 9 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS motif_trajet_label,
        CASE r.equipement_secu1
            WHEN 0 THEN 'Aucun équipement'::text
            WHEN 1 THEN 'Ceinture'::text
            WHEN 2 THEN 'Casque'::text
            WHEN 3 THEN 'Dispositif enfants'::text
            WHEN 4 THEN 'Gilet réfléchissant'::text
            WHEN 5 THEN 'Airbag (2RM/3RM)'::text
            WHEN 6 THEN 'Gants (2RM/3RM)'::text
            WHEN 7 THEN 'Gants + Airbag (2RM/3RM)'::text
            WHEN 8 THEN 'Non déterminable'::text
            WHEN 9 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS equipement_secu_1_label,
        CASE r.equipement_secu2
            WHEN 0 THEN 'Aucun équipement'::text
            WHEN 1 THEN 'Ceinture'::text
            WHEN 2 THEN 'Casque'::text
            WHEN 3 THEN 'Dispositif enfants'::text
            WHEN 4 THEN 'Gilet réfléchissant'::text
            WHEN 5 THEN 'Airbag (2RM/3RM)'::text
            WHEN 6 THEN 'Gants (2RM/3RM)'::text
            WHEN 7 THEN 'Gants + Airbag (2RM/3RM)'::text
            WHEN 8 THEN 'Non déterminable'::text
            WHEN 9 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS equipement_secu_2_label,
        CASE r.equipement_secu3
            WHEN 0 THEN 'Aucun équipement'::text
            WHEN 1 THEN 'Ceinture'::text
            WHEN 2 THEN 'Casque'::text
            WHEN 3 THEN 'Dispositif enfants'::text
            WHEN 4 THEN 'Gilet réfléchissant'::text
            WHEN 5 THEN 'Airbag (2RM/3RM)'::text
            WHEN 6 THEN 'Gants (2RM/3RM)'::text
            WHEN 7 THEN 'Gants + Airbag (2RM/3RM)'::text
            WHEN 8 THEN 'Non déterminable'::text
            WHEN 9 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS equipement_secu_3_label,
        CASE r.localisation_pieton
            WHEN 0 THEN 'Sans objet'::text
            WHEN 1 THEN 'A + 50 m du passage piéton'::text
            WHEN 2 THEN 'A – 50 m du passage piéton'::text
            WHEN 3 THEN 'Sans signalisation lumineuse'::text
            WHEN 4 THEN 'Avec signalisation lumineuse'::text
            WHEN 5 THEN 'Sur trottoir'::text
            WHEN 6 THEN 'Sur accotement'::text
            WHEN 7 THEN 'Sur refuge ou BAU'::text
            WHEN 8 THEN 'Sur contre allée'::text
            WHEN 9 THEN 'Inconnue'::text
            ELSE 'Non renseigné'::text
        END AS localisation_pieton_label,
        CASE r.action_pieton
            WHEN '0'::text THEN 'Non renseigné ou sans objet'::text
            WHEN '1'::text THEN 'Sens véhicule heurtant'::text
            WHEN '2'::text THEN 'Sens inverse du véhicule'::text
            WHEN '3'::text THEN 'Traversant'::text
            WHEN '4'::text THEN 'Masqué'::text
            WHEN '5'::text THEN 'Jouant – courant'::text
            WHEN '6'::text THEN 'Avec animal'::text
            WHEN '9'::text THEN 'Autre'::text
            WHEN 'A'::text THEN 'Monte/descend du véhicule'::text
            WHEN 'B'::text THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS action_pieton_label,
    (r.annee_source::double precision - r.annee_naissance)::integer AS age_victime_jour,
        CASE
            WHEN (r.annee_source::double precision - r.annee_naissance) < 18::double precision THEN 'Moins de 18 ans'::text
            WHEN (r.annee_source::double precision - r.annee_naissance) >= 18::double precision AND (r.annee_source::double precision - r.annee_naissance) <= 25::double precision THEN '18-25 ans'::text
            WHEN (r.annee_source::double precision - r.annee_naissance) >= 26::double precision AND (r.annee_source::double precision - r.annee_naissance) <= 45::double precision THEN '26-45 ans'::text
            WHEN (r.annee_source::double precision - r.annee_naissance) >= 46::double precision AND (r.annee_source::double precision - r.annee_naissance) <= 64::double precision THEN '46-64 ans'::text
            WHEN (r.annee_source::double precision - r.annee_naissance) >= 65::double precision THEN '65 ans et +'::text
            ELSE NULL::text
        END AS tranche_age
   FROM dim_usagers r
     LEFT JOIN fact_caracteristiques f ON r."Num_Acc" = f."Num_Acc";