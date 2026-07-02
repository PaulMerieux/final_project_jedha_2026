CREATE OR REPLACE VIEW public.view_caract AS
with
dim_vac_ameliore as (SELECT region, date
					FROM (SELECT v.date,
							     v."Departement", 
							     CASE WHEN d.region is null THEN v."Departement" ELSE d.region END as region	   
							FROM dim_vac_scolaire v
							LEFT JOIN ref_departements d
							ON d.nom_total = v."Departement"
							GROUP BY v.date, v."Departement", d.region)
					GROUP BY region, date
					ORDER BY region, date),

temp_caract as (SELECT r."Num_Acc",
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
					    t.region AS label_region,
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
					        END AS type_collision_label
					   FROM fact_caracteristiques r
					     LEFT JOIN ref_departements t ON t.code::text = lpad(r.departement, 2, '0'::text))



SELECT v.*, 
		CASE 
	        WHEN d.date IS NOT NULL THEN 'Vacances scolaires' 
	        ELSE 'hors vacances scolaires' 
	    END AS vacances_scolaires,
	    CASE 
	        WHEN d.date IS NOT NULL THEN 1 
	        ELSE 0 
	    END AS vacances_scolaires_flag
FROM temp_caract v

LEFT JOIN dim_vac_ameliore d

ON d.region = v.label_region
AND d.date::date = date(v.date)
