BEGIN; SELECT system.load_table('receptors', '{data_folder}/common/grid/25/grid.receptors_20250719.txt'); COMMIT;
BEGIN; SELECT system.load_table('hexagons', '{data_folder}/common/grid/25/grid.hexagons_20250719.txt'); COMMIT;



-- override: create hexagons-table with reduced precision:
INSERT INTO hexagons_reduced (receptor_id, zoom_level, geometry)
SELECT
	receptor_id,
	zoom_level, 
	ST_ReducePrecision(hexagons.geometry, 0.01) AS geometry

	FROM hexagons
; 
