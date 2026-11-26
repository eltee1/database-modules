/*
 * ae_buffer_with_tolerance
 * ------------------------
 * Function to return a buffered geometry, based on the GEOMETRY_TOLERANCE constant.
 * The tolerance which is used here, is half of the constant.
 * @param v_negative Use negative value of the constant (TRUE) or not (FALSE). 
 * the "join=mitre" option is to ensure that the sharp angles in the geometry remain instead of bering returned rounded (default is "join=round"). 
 */
CREATE OR REPLACE FUNCTION ae_buffer_with_tolerance (v_geometry geometry(MultiPolygon), v_negative boolean)
	RETURNS geometry(MultiPolygon) AS
$BODY$
	SELECT public.ST_CollectionExtract(
		public.ST_Multi(
			public.ST_MakeValid(
				public.ST_Buffer(v_geometry, 
					system.constant('GEOMETRY_TOLERANCE')::numeric * CASE WHEN v_negative THEN -0.5 ELSE 0.5 END,
					'join=mitre'
				)
			)
		),
	3)
$BODY$
LANGUAGE sql IMMUTABLE;


/*
 * buffer_with_tolerance_inward
 * ----------------------------
 * Function to return a inward buffered geometry, based on the ae_buffer_with_tolerance function.
 */
CREATE OR REPLACE FUNCTION buffer_with_tolerance_inward (v_geometry geometry(MultiPolygon))
	RETURNS geometry(MultiPolygon) AS
$BODY$
	SELECT public.ae_buffer_with_tolerance(v_geometry, TRUE)
$BODY$
LANGUAGE sql IMMUTABLE;


/*
 * buffer_with_tolerance_outward
 * -----------------------------
 * Function to return a outward buffered geometry, based on the ae_buffer_with_tolerance function.
 */
CREATE OR REPLACE FUNCTION buffer_with_tolerance_outward (v_geometry geometry(MultiPolygon))
	RETURNS geometry(MultiPolygon) AS
$BODY$
	SELECT public.ae_buffer_with_tolerance(v_geometry, FALSE)
$BODY$
LANGUAGE sql IMMUTABLE;
