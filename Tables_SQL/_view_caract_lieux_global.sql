CREATE OR REPLACE VIEW public.view_caract_lieux
 AS
 SELECT r."Num_Acc",
    r.luminosite,
    r.departement,
    r.commune,
    r.agglomeration,
    r.intersection,
    r.meteo,
    r.type_collision,
    r.lat,
    r.long,
    r.date,
    r.annee_source,
    t.nom_total AS label_departement,
        CASE
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 0::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 1::numeric THEN '00h - 02h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 2::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 3::numeric THEN '02h - 04h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 4::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 5::numeric THEN '04h - 06h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 6::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 7::numeric THEN '06h - 08h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 8::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 9::numeric THEN '08h - 10h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 10::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 11::numeric THEN '10h - 12h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 12::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 13::numeric THEN '12h - 14h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 14::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 15::numeric THEN '14h - 16h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 16::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 17::numeric THEN '16h - 18h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 18::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 19::numeric THEN '18h - 20h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 20::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 21::numeric THEN '20h - 22h'::text
            WHEN EXTRACT(hour FROM r.date::timestamp without time zone) >= 22::numeric AND EXTRACT(hour FROM r.date::timestamp without time zone) <= 23::numeric THEN '22h - 00h'::text
            ELSE 'Non renseigné'::text
        END AS tranche_horaire_label,
        CASE r.luminosite
            WHEN 1 THEN 'Plein jour'::text
            WHEN 2 THEN 'Crépuscule ou aube'::text
            WHEN 3 THEN 'Nuit sans éclairage public'::text
            WHEN 4 THEN 'Nuit avec éclairage public non allumé'::text
            WHEN 5 THEN 'Nuit avec éclairage public allumé'::text
            ELSE 'Inconnu'::text
        END AS luminosite_label,
        CASE r.agglomeration
            WHEN 1 THEN 'Hors agglomération'::text
            WHEN 2 THEN 'En agglomération'::text
            ELSE 'Inconnu'::text
        END AS agglomeration_label,
        CASE r.intersection
            WHEN 1 THEN 'Hors intersection'::text
            WHEN 2 THEN 'Intersection en X'::text
            WHEN 3 THEN 'Intersection en T'::text
            WHEN 4 THEN 'Intersection en Y'::text
            WHEN 5 THEN 'Intersection à plus de 4 branches'::text
            WHEN 6 THEN 'Giratoire'::text
            WHEN 7 THEN 'Place'::text
            WHEN 8 THEN 'Passage à niveau'::text
            ELSE 'Autre intersection'::text
        END AS intersection_label,
        CASE r.meteo
            WHEN 1 THEN 'Normale'::text
            WHEN 2 THEN 'Pluie légère'::text
            WHEN 3 THEN 'Pluie forte'::text
            WHEN 4 THEN 'Neige - grêle'::text
            WHEN 5 THEN 'Brouillard - fumée'::text
            WHEN 6 THEN 'Vent fort - tempête'::text
            WHEN 7 THEN 'Temps éblouissant'::text
            WHEN 8 THEN 'Temps couvert'::text
            WHEN 9 THEN 'Autre'::text
            ELSE 'Non renseigné'::text
        END AS meteo_label,
        CASE r.type_collision
            WHEN 1 THEN 'Deux véhicules - frontale'::text
            WHEN 2 THEN 'Deux véhicules – par l’arrière'::text
            WHEN 3 THEN 'Deux véhicules – par le coté'::text
            WHEN 4 THEN 'Trois véhicules et plus – en chaîne'::text
            WHEN 5 THEN 'Trois véhicules et plus - collisions multiples'::text
            WHEN 6 THEN 'Autre collision'::text
            WHEN 7 THEN 'Sans collision'::text
            ELSE 'Non renseigné'::text
        END AS type_collision_label,
        CASE l.categorie_route
            WHEN 1 THEN 'Autoroute'::text
            WHEN 2 THEN 'Route nationale'::text
            WHEN 3 THEN 'Route Départementale'::text
            WHEN 4 THEN 'Voie Communales'::text
            WHEN 5 THEN 'Hors réseau public'::text
            WHEN 6 THEN 'Parc de stationnement ouvert à la circulation publique'::text
            WHEN 7 THEN 'Routes de métropole urbaine'::text
            ELSE 'Autre'::text
        END AS categorie_route_label,
        CASE l.etat_surface
            WHEN 1 THEN 'Normale'::text
            WHEN 2 THEN 'Mouillée'::text
            WHEN 3 THEN 'Flaques'::text
            WHEN 4 THEN 'Inondée'::text
            WHEN 5 THEN 'Enneigée'::text
            WHEN 6 THEN 'Boue'::text
            WHEN 7 THEN 'Verglacée'::text
            WHEN 8 THEN 'Huile'::text
            ELSE 'Autre'::text
        END AS etat_surface_label,
        CASE l.infrastructure
            WHEN 0 THEN 'Aucun'::text
            WHEN 1 THEN 'Souterrain - tunnel'::text
            WHEN 2 THEN 'Pont - autopont'::text
            WHEN 3 THEN 'Bretelle d’échangeur ou de raccordement '::text
            WHEN 4 THEN 'Voie ferrée'::text
            WHEN 5 THEN 'Carrefour aménagé'::text
            WHEN 6 THEN 'Zone piétonne'::text
            WHEN 7 THEN 'Zone de péage'::text
            WHEN 8 THEN 'Chantier'::text
            ELSE 'Autre'::text
        END AS infrastucture_label
   FROM fact_caracteristiques r
     LEFT JOIN ref_departements t ON t.code::text = lpad(r.departement, 2, '0'::text)
     LEFT JOIN fact_lieux l ON r."Num_Acc" = l."Num_Acc";