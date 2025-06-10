extends Node

enum Direction {TOP, RIGHT, BOTTOM, LEFT}
enum Rotation {R0, R90, R180, R270}

@export var tiles: Array[Tile] = []
@export var type1_tiles: Array[Tile] = []
@export var type2_tiles: Array[Tile] = []
@export var type3_tiles: Array[Tile] = []
@export var end_tiles: Array[Tile] = []

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

func sample_direction(exceptions: Array[TileException]):
	var available_directions = [Direction.RIGHT, Direction.LEFT, Direction.BOTTOM]
	var current_room = exceptions.back()
	var prev_room = exceptions[exceptions.size()-2]
	if current_room.col == prev_room.col + 1:
		available_directions.erase(Direction.LEFT)
	if current_room.col == prev_room.col - 1:
		available_directions.erase(Direction.RIGHT)
	
	return available_directions.pick_random()

func generate_guaranteed_path(start_row, start_col, end_row, end_col) -> Array[TileException]:
	var exceptions: Array[TileException] = []
	
	var current_row = start_row
	var current_col = start_col
	
	var initial = TileException.new()
	initial.tile = type1_tiles.pick_random()
	initial.col = current_col
	initial.row = current_row
	exceptions.append(initial)
	
	while current_row < end_row:
		#pick direction
		var direction = sample_direction(exceptions)
		
		#determine next tile
		var next_row
		var next_col
		if direction == Direction.LEFT:
			if current_col > 0:
				next_col = current_col - 1
				next_row = current_row
			else:
				next_col = current_col
				next_row = current_row + 1
		if direction == Direction.RIGHT:
			if current_col < size.x-1:
				next_col = current_col + 1
				next_row = current_row
			else:
				next_col = current_col
				next_row = current_row + 1
		if direction == Direction.BOTTOM:
			next_col = current_col
			next_row = current_row + 1
		
		#add next room
		var next = TileException.new()
		if next_col != current_col:
			next.tile = type1_tiles.pick_random()
		if next_row != current_row:
			next.tile = type3_tiles.pick_random()
		if next_row == end_row:
			next.tile = end_tiles.pick_random()
		next.col = next_col
		next.row = next_row
		
		#change prev_room
		if next_row != current_row: 
			var prev = exceptions.back()
			prev.tile = type2_tiles.pick_random()
		
		#add next room
		exceptions.append(next)
		if next_row == end_row:
			break
		
		#update current idx
		current_col = next_col
		current_row = next_row
			
	
	return exceptions

func generate_map(exceptions: Array[TileException]=[]):
	var map = MathUtils.create_matrix(size, null)
	fill_exceptions(map, exceptions)
	for row in size.y:
		for col in size.x:
			set_new_tile(tiles, map, row, col)
	return map
	
func fill_exceptions(map, exceptions: Array[TileException]):
	for exception in exceptions:
		var step_info = StepResult.new()
		step_info.tile = exception.tile
		step_info.row =  exception.row; step_info.col =  exception.col;
		map[exception.row][exception.col] = step_info

func step_map(mapstep: MapStep, exceptions: Array[TileException]=[]):
	if mapstep.map == null:
		mapstep.map = MathUtils.create_matrix(size, null)
		mapstep.current_col = 0
		mapstep.current_row = 0
		fill_exceptions(mapstep.map, exceptions)
	
	var step_result = set_new_tile(tiles, mapstep.map, mapstep.current_row, mapstep.current_col)

	mapstep.current_col = (mapstep.current_col + 1) % size.x
	if mapstep.current_col == 0:
		mapstep.current_row += 1
		if mapstep.current_row >= size.y:
			mapstep.last_step = true
	return step_result
	
func set_new_tile(tiles: Array[Tile], map, row, col):
	if row == 0 and col == 0:
		var chosen_tile = tiles.pick_random()
		var step_info = StepResult.new()
		step_info.tile = chosen_tile
		step_info.row = 0; step_info.col = 0;
		map[row][col] = step_info
		return step_info
		
	if map[row][col] != null:
		return map[row][col] 
		
	var tile_top = null
	if row > 0:
		tile_top = map[row-1][col]
	
	var tile_left = null
	if col > 0:
		tile_left = map[row][col-1]
		
	var tile_bottom = null
	if row < map.size()-1:
		tile_bottom = map[row+1][col]
	
	var tile_right = null
	if col < map[0].size()-1:
		tile_right = map[row][col+1]
	
	var step_info_satisfing_constraints = get_tiles_statisfying_constraints_include_rotation(tiles, tile_top, tile_left, tile_bottom, tile_right)
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
	

func get_tiles_statisfying_constraints_include_rotation(tiles: Array[Tile],
	tile_top: StepResult, tile_left: StepResult, tile_bottom: StepResult, tile_right: StepResult) -> Array[StepResult]:
	var out: Array[StepResult] = []
	
	var bottom_direction_rotated_cos = Direction.BOTTOM 
	var right_direction_rotated_cos = Direction.RIGHT
	var top_direction_rotated_cos = Direction.TOP 
	var left_direction_rotated_cos = Direction.LEFT
	
	if tile_top:
		bottom_direction_rotated_cos = (Direction.BOTTOM + tile_top.rotation) % 4
	if tile_left:
		right_direction_rotated_cos = (Direction.RIGHT + tile_left.rotation) % 4
	if tile_bottom:
		top_direction_rotated_cos = (Direction.TOP + tile_bottom.rotation) % 4
	if tile_right:
		left_direction_rotated_cos = (Direction.LEFT + tile_right.rotation) % 4


	for tile in tiles:
		for rotation in [Rotation.R0, Rotation.R90, Rotation.R180, Rotation.R270]:
			var top_direction_rotated_new = (Direction.TOP + rotation) % 4
			var left_direction_rotated_new = (Direction.LEFT + rotation) % 4
			var bottom_direction_rotated_new = (Direction.BOTTOM + rotation) % 4
			var right_direction_rotated_new = (Direction.RIGHT + rotation) % 4
			
			if (not tile_top or tile.edges[top_direction_rotated_new] == tile_top.tile.edges[bottom_direction_rotated_cos]) and \
			   (not tile_left or tile.edges[left_direction_rotated_new] == tile_left.tile.edges[right_direction_rotated_cos]) and \
			   (not tile_bottom or tile.edges[bottom_direction_rotated_new] == tile_bottom.tile.edges[top_direction_rotated_cos]) and \
			   (not tile_right or tile.edges[right_direction_rotated_new] == tile_right.tile.edges[left_direction_rotated_cos]) :
					var step_info = StepResult.new()
					step_info.tile = tile
					step_info.rotation = rotation
					out.append(step_info)
				
	return out
