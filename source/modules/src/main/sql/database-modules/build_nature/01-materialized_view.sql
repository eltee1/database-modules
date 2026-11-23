/*
 * assessment_areas_buffered
 * -------------------------
 * Materialized view to return a subset of assessment_areas, extended with a geometry_buffered column which is used in the tolerance-implementation 
 * during the nature-grid build. In that part of the build, this materialized view is used instead of the parent-table assessment_areas.
 */
CREATE MATERIALIZED VIEW assessment_areas_buffered AS
SELECT
	assessment_area_id,
	type,
	geometry,
	ae_buffer_with_tolerance (geometry, TRUE) AS geometry_buffered
	
	FROM assessment_areas
;

CREATE UNIQUE INDEX	idx_assessment_areas_buffered ON assessment_areas_buffered (assessment_area_id);
CREATE INDEX idx_assessment_areas_buffered_geometry_gist ON assessment_areas_buffered USING GIST (geometry);
CREATE INDEX idx_assessment_areas_buffered_geometry_buffered_gist ON assessment_areas_buffered USING GIST (geometry_buffered);


/*
 * natura2000_directive_areas_buffered
 * -----------------------------------
 * Materialized view to return a subset of natura2000_directive_areas, extended with a geometry_buffered column which is used in the tolerance-implementation 
 * during the nature-grid build. In that part of the build, this materialized view is used instead of the parent-table natura2000_directive_areas.
 */
CREATE MATERIALIZED VIEW natura2000_directive_areas_buffered AS
SELECT
	natura2000_area_id,
	natura2000_directive_area_id,
	natura2000_directive_id,
	ae_buffer_with_tolerance (geometry, TRUE) AS geometry_buffered

	FROM natura2000_directive_areas
;

CREATE UNIQUE INDEX	idx_natura2000_directive_areas_buffered ON natura2000_directive_areas_buffered (natura2000_area_id, natura2000_directive_area_id);
CREATE INDEX idx_natura2000_directive_areas_buffered_geometry_buffered_gist ON natura2000_directive_areas_buffered USING GIST (geometry_buffered);


/*
 * habitat_areas_buffered
 * ----------------------
 * Materialized view to return a subset of assessment_areas, extended with a geometry_buffered column which is used in the tolerance-implementation 
 * during the nature-grid build. In that part of the build, this materialized view is used instead of the parent-table habitat_areas.
 */
CREATE MATERIALIZED VIEW habitat_areas_buffered AS
SELECT
	assessment_area_id,
	habitat_area_id,
	habitat_type_id,
	coverage,
	geometry,
	ae_buffer_with_tolerance (geometry, TRUE) AS geometry_buffered

	FROM habitat_areas
;

CREATE UNIQUE INDEX	idx_habitat_areas_buffered ON habitat_areas_buffered (habitat_area_id);
CREATE INDEX idx_habitat_areas_buffered_assessment_area_id ON habitat_areas_buffered (assessment_area_id);
CREATE INDEX idx_habitat_areas_buffered_geometry_gist ON habitat_areas_buffered USING GIST (geometry);
CREATE INDEX idx_habitat_areas_buffered_geometry_buffered_gist ON habitat_areas_buffered USING GIST (geometry_buffered);
