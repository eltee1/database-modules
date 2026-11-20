--
-- habitats and species
--
--  Refresh buffered materialized views
BEGIN; REFRESH MATERIALIZED VIEW nature.natura2000_directive_areas_buffered; COMMIT;
BEGIN; REFRESH MATERIALIZED VIEW nature.habitat_areas_buffered; COMMIT;

SELECT system.raise_notice('Build: relevant_habitat_areas @ ' || timeofday());
{multithread on: SELECT assessment_area_id FROM nature.assessment_areas ORDER BY assessment_area_id}

	INSERT INTO nature.relevant_habitat_areas (assessment_area_id, habitat_area_id, habitat_type_id, coverage, geometry)
		SELECT 
			assessment_area_id,
			habitat_area_id,
			habitat_type_id,
			coverage,
			geometry
		
		FROM nature.build_relevant_habitat_areas_view
		
		WHERE assessment_area_id = {assessment_area_id};
	
{/multithread}
