 CREATE OR REPLACE VIEW public.view_lieux AS
 WITH lieux AS (
         SELECT fact_lieux."Num_Acc",
            fact_lieux.categorie_route,
            fact_lieux.regime_circulation,
            fact_lieux.nb_voies,
            fact_lieux.profil_route,
            fact_lieux.etat_surface,
            fact_lieux.infrastructure,
            fact_lieux.situation_accident,
            fact_lieux.vitesse_max_autorisee,
            fact_lieux.annee_source,
                CASE fact_lieux.categorie_route
                    WHEN 1 THEN 'Autoroute'::text
                    WHEN 2 THEN 'Nationale'::text
                    WHEN 3 THEN 'Départementale'::text
                    WHEN 4 THEN 'Communales'::text
                    WHEN 5 THEN 'Hors réseau public'::text
                    WHEN 6 THEN 'Parc de stationnement ouvert à la circulation publique'::text
                    WHEN 7 THEN 'Routes de métropole urbaine'::text
                    ELSE 'Autre'::text
                END AS categorie_route_label,
                CASE fact_lieux.etat_surface
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
                CASE fact_lieux.infrastructure
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
           FROM fact_lieux
        )

 SELECT "Num_Acc",
    categorie_route,
    regime_circulation,
    nb_voies,
    profil_route,
    etat_surface,
    infrastructure,
    situation_accident,
    vitesse_max_autorisee,
    annee_source,
    categorie_route_label,
    etat_surface_label,
    infrastucture_label
   FROM lieux
  WHERE (vitesse_max_autorisee::integer % 10) <> 0;
