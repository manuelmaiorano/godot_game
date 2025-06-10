extends Node

enum Direction {TOP, RIGHT, BOTTOM, LEFT}
enum Rotation {R0, R90, R180, R270}

@export var tiles: Array[Tile] = []
@export var size: Vector2i = Vector2i.ZERO

class MapStep:
	var map = null
	var current_row = 0
	var current_col = 0
	var last_step = false
	
class StepResult:
	var tile = null
	var rotation = Rotation.R0
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

func generate_map(exceptions: Array[StepResult]=[]):
	var map = MathUtils.create_matrix(size, null)
	for row in size.y:
		for col in size.x:
			set_new_tile(tiles, map, row, col, exceptions)
			#print_map(map)
			#print()
			
	return map

func step_map(mapstep: MapStep, exceptions: Array[StepResult]=[]):
	if mapstep.map == null:
		mapstep.map = MathUtils.create_matrix(size, null)
		mapstep.current_col = 0
		mapstep.current_row = 0
	
	var step_result = set_new_tile(tiles, mapstep.map, mapstep.current_row, mapstep.current_col, exceptions)

	mapstep.current_col = (mapstep.current_col + 1) % size.x
	if mapstep.current_col == 0:
		mapstep.current_row += 1
		if mapstep.current_row >= size.y:
			mapstep.last_step = true
	return step_result
	
func set_new_tile(tiles: Array[Tile], map, row, col, exceptions: Array[StepResult]=[]):
	
	for exception in exceptions:
		if exception.row == row and exception.col == col:
			map[row][col] = exception
			return exception
			
	if row == 0 and col == 0:
		var chosen_tile = tiles.pick_random()
		var step_info = StepResult.new()
		step_info.tile = chosen_tile
		step_info.row = 0; step_info.col = 0;
		map[row][col] = step_info
		return step_info
		
	#constraint_top
	var tile_top = null
	if row > 0:
		tile_top = map[row-1][col]
	
	#constraint_left
	var tile_left = null
	if col > 0:
		tile_left = map[row][col-1]
	
	var step_info_satisfing_constraints = get_tiles_statisfying_constraints_include_rotation(tiles, tile_top, tile_left)
	assert(not step_info_satisfing_constraints.is_empty())
	
	var step_info = step_info_satisfing_constraints.pick_random()
	
	step_info.row = row; step_info.col = col;
	map[row][col] = step_info
	return step_info

func get_tiles_statisfying_constraints(tiles: Array[Tile], tile_top: StepResult, tile_left: StepResult) -> Array[StepResult]:
	var out: Array[StepResult] = []
	for tile in tiles:
		if (not tile_top or tile.edges[Direction.TOP] == tile_top.tile.edges[Direction.BOTTOM]) and \
		   (not tile_left or tile.edges[Direction.LEFT] == tile_left.tile.edges[Direction.RIGHT]):
				var step_info = StepResult.new()
				step_info.tile = tile
				out.append(step_info)
				
	return out
	

func get_tiles_statisfying_constraints_include_rotation(tiles: Array[Tile], tile_top: StepResult, tile_left: StepResult) -> Array[StepResult]:
	var out: Array[StepResult] = []
	for tile in tiles:
		for rotation in [Rotation.R0, Rotation.R90, Rotation.R180, Rotation.R270]:
			var top_direction_rotated = (Direction.TOP + rotation) % 4
			var left_direction_rotated = (Direction.LEFT + rotation) % 4
			
			var bottom_direction_rotated = Direction.BOTTOM 
			var right_direction_rotated = Direction.RIGHT
			if tile_top:
				if tile_top.rotation > 0:
					pass
				bottom_direction_rotated = (Direction.BOTTOM + tile_top.rotation) % 4
			if tile_left:
				right_direction_rotated = (Direction.RIGHT + tile_left.rotation) % 4
			
			if (not tile_top or tile.edges[top_direction_rotated] == tile_top.tile.edges[bottom_direction_rotated]) and \
			   (not tile_left or tile.edges[left_direction_rotated] == tile_left.tile.edges[right_direction_rotated]):
					var step_info = StepResult.new()
					step_info.tile = tile
					step_info.rotation = rotation
					out.append(step_info)
				
	return out
