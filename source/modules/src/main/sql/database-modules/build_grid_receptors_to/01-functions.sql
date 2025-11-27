/*
 * ae_determine_hexagon_intersections
 * ----------------------------------
 * Function to determine the intersections of our hexagons with a supplied geometry.
 * This is based on the hexagons in the hexagons table, not every possible hexagons imaginable.
 * Inspired by https://web.archive.org/web/20150504125339/http://dimensionaledge.com/intro-vector-tiling-map-reduce-postgis/.
 * @param v_geometry The geometry to determine intersects for.
 * @param v_gridsize The size of the used grids in kilometers.
 */
-- Override function for reduced precision for geometry: tot 1 cm.
CREATE OR REPLACE FUNCTION ae_determine_hexagon_intersections(v_geometry geometry(MultiPolygon), v_gridsize integer = 1)
	RETURNS TABLE(receptor_id integer, surface double precision, geometry geometry, zoom_level smallint) AS
$BODY$
	WITH
	split_geometry AS (
		SELECT (ST_Dump(v_geometry)).geom AS split_geometry
	),
	regular_grid AS (
		SELECT ae_create_regular_grid(ST_Envelope(v_geometry), v_gridsize * 1000)::geometry(Polygon) AS regular_geometry
	),
	intersected AS (
		SELECT
			CASE
				WHEN ST_Within(regular_geometry, split_geometry)
				THEN regular_geometry
				ELSE ST_Intersection(regular_geometry, split_geometry) END AS geometry
			FROM regular_grid
				INNER JOIN split_geometry ON ST_Intersects(regular_geometry, split_geometry) AND regular_geometry && split_geometry
	),
	vector_tiles AS (
		SELECT (ST_Dump(intersected.geometry)).geom AS geometry	FROM intersected WHERE intersected.geometry IS NOT NULL
	),
	intersected_areas AS (
		SELECT
			receptor_id,
			ST_Intersection(vector_tiles.geometry, hexagons.geometry) AS geometry,
			zoom_level

			FROM vector_tiles
				INNER JOIN hexagons_reduced AS hexagons ON ST_Intersects(vector_tiles.geometry, hexagons.geometry) -- hier dus

			WHERE zoom_level = ANY(string_to_array(system.constant('RESULT_ZOOM_LEVELS'), ',')::int[])
	),
	unioned_intersected_areas AS (
		SELECT
			intersected_areas.receptor_id,
			ST_Union(intersected_areas.geometry) AS geometry,
			intersected_areas.zoom_level

			FROM intersected_areas
			
			GROUP BY intersected_areas.receptor_id, intersected_areas.zoom_level
	)
	SELECT
		unioned_intersected_areas.receptor_id,
		ST_Area(unioned_intersected_areas.geometry) AS surface,
		ST_ReducePrecision(unioned_intersected_areas.geometry, 0.01) as geometry, -- en voor de zekerheid de reduced precision retourneren.
		unioned_intersected_areas.zoom_level

		FROM unioned_intersected_areas

		WHERE ST_Area(unioned_intersected_areas.geometry) > 0;
$BODY$
LANGUAGE sql VOLATILE;