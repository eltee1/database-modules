/*
 * build_receptors_to_assessment_areas_tolerance_view
 * --------------------------------------------------
 * View to fill the receptors_to_assessment_areas table.
 */
CREATE OR REPLACE VIEW build_receptors_to_assessment_areas_tolerance_view AS
SELECT
	assessment_area_id,
	original.receptor_id,
	reduced.receptor_id IS NOT NULL AS is_robust_intersect,
	zoom_level,
	surface

	FROM 
		(SELECT
			assessment_area_id,
			(ae_determine_hexagon_intersections(geometry)).receptor_id,
			(ae_determine_hexagon_intersections(geometry)).surface,
			(ae_determine_hexagon_intersections(geometry)).zoom_level
			
			FROM nature.assessment_areas
			
			WHERE type = 'natura2000_area'
		) AS original
		LEFT JOIN 
			(SELECT
				assessment_area_id,
				(ae_determine_hexagon_intersections(geometry_buffered)).receptor_id,
				(ae_determine_hexagon_intersections(geometry_buffered)).zoom_level
				
				FROM nature.assessment_areas_buffered
				
				WHERE type = 'natura2000_area'
			) AS reduced
		USING (assessment_area_id, receptor_id, zoom_level)
;


/*
 * build_receptors_to_critical_deposition_areas_tolerance_view
 * -----------------------------------------------------------
 * View to fill the receptors_to_critical_deposition_areas table.
 *
 * The coverage of the habitat on each receptor is calculated by looking at the intersection of the habitat areas that intersect the receptor.
 * See {@link ae_determine_habitat_coverage_on_hexagon} for the calculation method.
 */
CREATE OR REPLACE VIEW build_receptors_to_critical_deposition_areas_tolerance_view AS
SELECT
	assessment_area_id,
	type,
	critical_deposition_area_id,
	original.receptor_id,
	zoom_level,
	reduced.receptor_id IS NOT NULL AS is_robust_intersect,
	surface,
	ae_determine_habitat_coverage_on_hexagon(assessment_area_id, type, critical_deposition_area_id, receptor_id, zoom_level::integer) AS receptor_habitat_coverage

	FROM 
		(SELECT
			assessment_area_id,
			type,
			critical_deposition_area_id,
			(ae_determine_hexagon_intersections(geometry)).receptor_id,
			(ae_determine_hexagon_intersections(geometry)).surface,
			(ae_determine_hexagon_intersections(geometry)).zoom_level
		
			FROM nature.critical_deposition_areas_buffered
		) AS original
		LEFT JOIN 
			(SELECT
				assessment_area_id,
				type,
				critical_deposition_area_id,
				(ae_determine_hexagon_intersections(geometry_buffered)).receptor_id,
				(ae_determine_hexagon_intersections(geometry_buffered)).zoom_level
			FROM nature.critical_deposition_areas_buffered
			) AS reduced
		USING (assessment_area_id, type, critical_deposition_area_id, receptor_id, zoom_level)
;
