-- Refresh buffered materialized view
BEGIN; REFRESH MATERIALIZED VIEW nature.assessment_areas_buffered; COMMIT;


-- build
SELECT system.raise_notice('Build: receptors_to_assessment_areas @ ' || timeofday());
{multithread on: SELECT assessment_area_id FROM nature.assessment_areas ORDER BY assessment_area_id}
	SET search_path TO 'grid', 'public';
	INSERT INTO grid.receptors_to_assessment_areas_tolerance (receptor_id, assessment_area_id, zoom_level, is_robust_intersect, surface)
	SELECT
		receptor_id,
		assessment_area_id,
		zoom_level,
		is_robust_intersect,
		surface

		FROM grid.build_receptors_to_assessment_areas_tolerance_view
		
		WHERE assessment_area_id = {assessment_area_id}
	;

{/multithread}


-- Fill the original table with the data where tolerance has been taken into account
BEGIN;
	INSERT INTO grid.receptors_to_assessment_areas (receptor_id, assessment_area_id, zoom_level, surface)
	SELECT
		receptor_id,
		assessment_area_id,
		zoom_level,
		surface

		FROM grid.receptors_to_assessment_areas_tolerance

		WHERE is_robust_intersect IS TRUE

		ORDER BY
			receptor_id,
			assessment_area_id,
			zoom_level
	;
COMMIT;


SELECT system.raise_notice('Build: critical_deposition_areas @ ' || timeofday());
BEGIN;
	INSERT INTO nature.critical_deposition_areas_buffered (assessment_area_id, type, critical_deposition_area_id, name, description, relevant, geometry, geometry_buffered)
	SELECT 
		assessment_area_id,
		type,
		critical_deposition_area_id,
		name,
		description,
		relevant,
		geometry,
		ST_Buffer(geometry, system.constant('INTERSECTION_TOLERANCE')::numeric) AS geometry_buffered

		FROM nature.critical_deposition_areas_view 
	;
COMMIT;


SELECT system.raise_notice('Build: receptors_to_critical_deposition_areas @ ' || timeofday());
{multithread on: SELECT assessment_area_id, critical_deposition_area_type FROM nature.assessment_areas CROSS JOIN (SELECT unnest(enum_range(null::public.critical_deposition_area_type)) AS critical_deposition_area_type) AS types ORDER BY assessment_area_id, critical_deposition_area_type }
	SET search_path TO 'grid', 'public';
	INSERT INTO grid.receptors_to_critical_deposition_areas_tolerance (assessment_area_id, type, critical_deposition_area_id, receptor_id, zoom_level, is_robust_intersect, surface, receptor_habitat_coverage)
	SELECT 
		assessment_area_id,
		type,
		critical_deposition_area_id,
		receptor_id,
		zoom_level,
		is_robust_intersect,
		surface,
		receptor_habitat_coverage

		FROM grid.build_receptors_to_critical_deposition_areas_tolerance_view 
		
		WHERE 
			assessment_area_id = {assessment_area_id}
			AND type = '{critical_deposition_area_type}'
	;

{/multithread}


-- Fill the original table with the data where tolerance has been taken into account
BEGIN;
	INSERT INTO grid.receptors_to_critical_deposition_areas (assessment_area_id, type, critical_deposition_area_id, receptor_id, zoom_level, surface, receptor_habitat_coverage)
	SELECT
		assessment_area_id,
		type,
		critical_deposition_area_id,
		receptor_id,
		zoom_level,
		surface,
		receptor_habitat_coverage

		FROM grid.receptors_to_critical_deposition_areas_tolerance

		WHERE is_robust_intersect IS TRUE

		ORDER BY
			assessment_area_id,
			type,
			critical_deposition_area_id,
			receptor_id,
			zoom_level
	;
COMMIT;
