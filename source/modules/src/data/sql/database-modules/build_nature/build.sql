--
-- habitats and species
--
SELECT system.raise_notice('Build: relevant_habitat_areas @ ' || timeofday());
BEGIN;
	INSERT INTO relevant_habitat_areas(assessment_area_id, habitat_area_id, habitat_type_id, coverage, geometry)
		SELECT assessment_area_id, habitat_area_id, habitat_type_id, coverage, geometry
		FROM build_relevant_habitat_areas_view;
COMMIT;


-- build assessment_areas_reduced
BEGIN;
	INSERT INTO nature.assessment_areas_reduced (assessment_area_id, type, name, code, authority_id, geometry)
	SELECT 
		assessment_area_id, 
		type, 
		name, 
		code, 
		authority_id, 
		ST_ReducePrecision(geometry, 0.01)

		FROM nature.assessment_areas

		WHERE type = 'natura2000_area'
	;
COMMIT;


-- build habitat_areas_reduced
BEGIN;
	INSERT INTO nature.habitat_areas_reduced (assessment_area_id, habitat_area_id, habitat_type_id, coverage, geometry)
	SELECT
		assessment_area_id,
		habitat_area_id,
		habitat_type_id,
		coverage,
		ST_ReducePrecision(geometry, 0.01) AS geometry

		FROM nature.habitat_areas
	; 
COMMIT;


-- build relevant_habitat_areas_reduced
BEGIN;
	INSERT INTO nature.relevant_habitat_areas_reduced (assessment_area_id, habitat_area_id, habitat_type_id, coverage, geometry)
	SELECT
		assessment_area_id,
		habitat_area_id,
		habitat_type_id,
		coverage,
		ST_ReducePrecision(geometry, 0.01) AS geometry

		FROM nature.relevant_habitat_areas
	; 
COMMIT;
