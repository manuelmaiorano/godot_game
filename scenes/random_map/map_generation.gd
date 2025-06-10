extends Node3D

@export var tile_size: Vector2
@export var exceptions: Array[TileException]

@onready var tiles: Node3D = %Tiles

var current_map_step: RandomMapGeneration.MapStep = null

var tile_frequency = {}

func _ready() -> void:
	pass
	
func _on_full_button_up() -> void:
	populate_map()
	print(tile_frequency)

func _on_step_button_up() -> void:
	if current_map_step == null:
		clear()
		current_map_step = RandomMapGeneration.MapStep.new()
	
	if current_map_step.last_step:
		current_map_step = null
		clear()
		return
	
	var step_res = RandomMapGeneration.step_map(current_map_step)
	add_tile(step_res)

func populate_map():
	clear()
	
	var exceptions = RandomMapGeneration.generate_guaranteed_path(0, 5, 9, 5)
	var map = RandomMapGeneration.generate_map(exceptions)
	for row in map.size():
		for column in map[0].size():
			var step_res = map[row][column]
			add_tile(step_res)
			
	for exception in exceptions:
		add_debug_mesh(exception)
		
func add_debug_mesh(exception):
	var instance = preload("res://scripts/random_map_generation/debug_mesh.tscn").instantiate()
	tiles.add_child(instance)
	instance.global_position = Vector3(tile_size.x * exception.col, 0, tile_size.y * exception.row)

func clear():
	tile_frequency = {}
	current_map_step = null
	for child in tiles.get_children():
		child.queue_free()
		
func add_tile(step_res: RandomMapGeneration.StepResult):
	add_tile_freq_data(step_res.tile)
	var tile = step_res.tile
	var tile_scene = tile.scene
	var instance = tile_scene.instantiate()
	tiles.add_child(instance)
	instance.global_position = Vector3(tile_size.x * step_res.col, 0, tile_size.y * step_res.row)
	instance.rotate_y(deg_to_rad(step_res.rotation * 90))
	
func add_tile_freq_data(tile: Tile):
	if tile_frequency.has(tile.id):
		tile_frequency[tile.id] += 1
	else:
		tile_frequency[tile.id] = 1
	
