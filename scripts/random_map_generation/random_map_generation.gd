extends Node

enum Direction {TOP, RIGHT, BOTTOM, LEFT}

@export var tiles: Array[Tile] = []
@export var size: Vector2i = Vector2i.ZERO

class MapStep:
	var map = null
	var current_row = 0
	var current_col = 0
	var last_step = false
	
class StepResult:
	var tile = null
	var row = 0
	var col = 0

func _ready() -> void:
	return
	seed(12345)
	var map = generate_map()

func print_map(map):
	for y in map.size():
		var s = ""
		for x in map[y]:
			if x:
				s = s + x.debug_str
			else:
				s = s+"@"
		print(s)

func generate_map():
	var map = MathUtils.create_matrix(size, null)
	for row in size.y:
		for col in size.x:
			set_new_tile(tiles, map, row, col)
			#print_map(map)
			#print()
			
	return map

func step_map(mapstep: MapStep):
	if mapstep.map == null:
		mapstep.map = MathUtils.create_matrix(size, null)
		mapstep.current_col = 0
		mapstep.current_row = 0
	
	var step_result = StepResult.new()
	var chosen_tile = set_new_tile(tiles, mapstep.map, mapstep.current_row, mapstep.current_col)
	step_result.tile = chosen_tile
	step_result.row = mapstep.current_row
	step_result.col = mapstep.current_col

	mapstep.current_col = (mapstep.current_col + 1) % size.x
	if mapstep.current_col == 0:
		mapstep.current_row += 1
		if mapstep.current_row >= size.y:
			mapstep.last_step = true
	return step_result
	
func set_new_tile(tiles: Array[Tile], map, row, col):

	if row == 0 and col == 0:
		var chosen_tile = tiles.pick_random()
		print(chosen_tile.id)
		map[row][col] = chosen_tile
		return chosen_tile
		
	#constraint_top
	var tile_top = null
	if row > 0:
		tile_top = map[row-1][col]
	
	#constraint_left
	var tile_left = null
	if col > 0:
		tile_left = map[row][col-1]
	
	var tiles_satisfing_constraints = []
	tiles_satisfing_constraints = tiles.filter(func(x: Tile): return not tile_top or x.edges[Direction.TOP] == tile_top.edges[Direction.BOTTOM])
	
	tiles_satisfing_constraints = tiles_satisfing_constraints\
				.filter(func(x: Tile): return not tile_left or x.edges[Direction.LEFT] == tile_left.edges[Direction.RIGHT])
	assert(not tiles_satisfing_constraints.is_empty())
	print(tiles_satisfing_constraints.size())
	
	var chosen_tile = tiles_satisfing_constraints.pick_random()
	map[row][col] = chosen_tile
	return chosen_tile
