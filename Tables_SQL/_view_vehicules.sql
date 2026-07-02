 CREATE OR REPLACE VIEW public.view_vehicules
 AS
 SELECT "Num_Acc",
    id_vehicule,
    categorie_vehicule,
    obstacle_fixe,
    obstacle_mobile,
    motorisation,
    annee_source,
        CASE 
            WHEN categorie_vehicule = 36::double precision THEN 'Quad lourd (>50cc)'::text
            WHEN categorie_vehicule = ANY (ARRAY[33::double precision, 34::double precision]) THEN 'Moto >125cc'::text
            WHEN categorie_vehicule = ANY (ARRAY[2::double precision, 30::double precision, 31::double precision, 32::double precision]) THEN 'Cyclomoteur <50cc'::text
            WHEN categorie_vehicule = 1::double precision THEN 'Bicyclette'::text
            WHEN categorie_vehicule = ANY (ARRAY[3::double precision, 7::double precision]) THEN 'Voiture légère (VL)'::text
            WHEN categorie_vehicule = 10::double precision THEN 'Véhicules Utilitaires (VU)'::text
            WHEN categorie_vehicule = ANY (ARRAY[13, 14, 15, 16, 17]) THEN 'Poids Lourds (PL)'::text
            WHEN categorie_vehicule = ANY (ARRAY[37, 38, 39, 40]) THEN 'Transports en commun'::text
            WHEN categorie_vehicule = ANY (ARRAY[50, 60, 80]) THEN 'Autres Mobilités (EDP)'::text
            WHEN categorie_vehicule = ANY (ARRAY[20, 21, 35]) THEN 'Engins spéciaux et agricoles'::text
            WHEN categorie_vehicule = ANY (ARRAY[0, 99]) THEN 'Inconnu ou Autre'::text
            ELSE 'Autres/Non renseigné'::text
        END AS categorie_vehicule_label,
        CASE obstacle_fixe
            WHEN 0 THEN 'Sans objet'::text
            WHEN 1 THEN 'Véhicule en stationnement'::text
            WHEN 2 THEN 'Arbre'::text
            WHEN 3 THEN 'Glissière métallique'::text
            WHEN 4 THEN 'Glissière béton'::text
            WHEN 5 THEN 'Autre glissière'::text
            WHEN 6 THEN 'Bâtiment, mur, pile de pont'::text
            WHEN 7 THEN 'poste d’appel d’urgence'::text
            WHEN 8 THEN 'Poteau'::text
            WHEN 9 THEN 'Mobilier urbain'::text
            WHEN 10 THEN 'Parapet'::text
            WHEN 11 THEN 'Ilot, refuge, borne haute'::text
            WHEN 12 THEN 'Bordure de trottoir'::text
            WHEN 13 THEN 'Fossé, talus, paroi rocheuse'::text
            WHEN 14 THEN 'Autre obstacle fixe sur chaussée'::text
            WHEN 15 THEN 'Autre obstacle fixe sur trottoir'::text
            WHEN 16 THEN 'Sortie de chaussée sans obstacle'::text
            WHEN 17 THEN 'Buse – tête d’aqueduc'::text
            ELSE 'Non renseigné'::text
        END AS obstacle_fixe_label,
        CASE obstacle_mobile
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
        END AS obstacle_mobile_label,
        CASE motorisation
            WHEN 0 THEN 'Inconnue'::text
            WHEN 1 THEN 'Hydrocarbures'::text
            WHEN 2 THEN 'Hybride électrique'::text
            WHEN 3 THEN 'Electrique'::text
            WHEN 4 THEN 'Hydrogène'::text
            WHEN 5 THEN 'Humaine'::text
            WHEN 6 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS motorisation_label
   FROM dim_vehicules r;