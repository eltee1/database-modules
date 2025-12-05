SELECT system.raise_notice('Build: geometry_of_interests @ ' || timeofday());
BEGIN; SELECT grid.ae_build_geometry_of_interests(); COMMIT;

SELECT system.raise_notice('Build: hexagons and receptors @ ' || timeofday());
BEGIN; SELECT grid.ae_build_hexagons_and_receptors(); COMMIT;

-- build hexagons_reduced
BEGIN;
	INSERT INTO grid.hexagons_reduced (receptor_id, zoom_level, geometry)
	SELECT
		receptor_id,
		zoom_level, 
		ST_ReducePrecision(geometry, 0.01) AS geometry
		FROM grid.hexagons
	; 
COMMIT;
