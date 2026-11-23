
/*
 * ae_get_buffered_geometry
 * ------------------------
 * Function to return a buffered geometry, based on the INTERSECTION_TOLERANCE.
 * the "join=mitre" option is to ensure that the sharp angles remain instead of bering returned rounded (default is "join=round"). 
 */
CREATE OR REPLACE FUNCTION ae_get_buffered_geometry(v_geometry geometry(MultiPolygon))
	RETURNS geometry(MultiPolygon) AS
$BODY$
	SELECT public.ST_Buffer(v_geometry, system.constant('INTERSECTION_TOLERANCE')::numeric, 'join=mitre')
$BODY$
LANGUAGE sql IMMUTABLE;
