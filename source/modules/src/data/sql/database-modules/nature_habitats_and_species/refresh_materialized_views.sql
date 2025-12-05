-- Refresh all materialized views
BEGIN; REFRESH MATERIALIZED VIEW habitats; COMMIT;
BEGIN; REFRESH MATERIALIZED VIEW relevant_habitats; COMMIT;
BEGIN; REFRESH MATERIALIZED VIEW relevant_goal_habitats; COMMIT;
BEGIN; REFRESH MATERIALIZED VIEW relevant_species; COMMIT;



BEGIN;
	INSERT INTO nature.critical_deposition_areas_reduced (assessment_area_id, type, critical_deposition_area_id, name, description, relevant, geometry)
	SELECT
		assessment_area_id,
		'relevant_habitat'::public.critical_deposition_area_type AS type,
		habitat_type_id AS critical_deposition_area_id,
		name,
		description,
		TRUE AS relevant,
		ST_ReducePrecision(geometry, 0.01) 

		FROM nature.relevant_habitats
			INNER JOIN nature.habitat_types USING (habitat_type_id)
	;
COMMIT;
