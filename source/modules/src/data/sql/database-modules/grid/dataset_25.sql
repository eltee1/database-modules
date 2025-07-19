BEGIN; SELECT system.load_table('receptors', '{data_folder}/common/grid/25/grid.receptors_20250719.txt'); COMMIT;
BEGIN; SELECT system.load_table('hexagons', '{data_folder}/common/grid/25/grid.hexagons_20250719.txt'); COMMIT;

BEGIN; SELECT system.load_table('geometry_of_interests', '{data_folder}/common/grid/25/grid.geometry_of_interests_20250719.txt'); COMMIT;
