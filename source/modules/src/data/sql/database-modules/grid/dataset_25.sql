BEGIN; SELECT system.load_table('receptors', '{data_folder}/common/grid/25/grid.receptors_v2_20260217.txt'); COMMIT;
BEGIN; SELECT system.load_table('hexagons', '{data_folder}/common/grid/25/grid.hexagons_v2_20260217.txt'); COMMIT;
