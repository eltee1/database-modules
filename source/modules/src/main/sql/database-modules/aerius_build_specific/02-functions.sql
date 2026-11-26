
/*
 * ae_buffer_with_tolerance
 * ------------------------
 * Function to return a buffered geometry, based on the INTERSECTION_TOLERANCE.
 * @param v_negative Use negative value of the constant (TRUE) or not (FALSE). 
 * the "join=mitre" option is to ensure that the sharp angles in the geometry remain instead of bering returned rounded (default is "join=round"). 
 */
CREATE OR REPLACE FUNCTION ae_buffer_with_tolerance (v_geometry geometry(MultiPolygon), v_negative boolean)
	RETURNS geometry(MultiPolygon) AS
$BODY$

	SELECT ST_CollectionExtract(
				ST_Multi(
					ST_MakeValid(
						public.ST_Buffer(v_geometry, 
							CASE 
								WHEN v_negative THEN -system.constant('INTERSECTION_TOLERANCE')::numeric 
								ELSE system.constant('INTERSECTION_TOLERANCE')::numeric 
							END
							, 'join=mitre'
						)
					)
				)
			, 3)
$BODY$
LANGUAGE sql IMMUTABLE;
