extends Node3D

@export var tile_size: Vector2
@onready var tiles: Node3D = %Tiles

var current_map_step: RandomMapGeneration.MapStep = null

func _ready() -> void:
	pass

func populate_map():
	clear()
		
	var map = RandomMapGeneration.generate_map()
	for row in map.size():
		for column in map[0].size():
			var tile = map[row][column]
			add_tile(tile, row, column)
	
func _on_full_button_up() -> void:
	populate_map()

func clear():
	current_map_step = null
	for child in tiles.get_children():
		child.queue_free()
		
func add_tile(tile: Tile, row, column):
	var tile_scene = tile.scene
	var instance = tile_scene.instantiate()
	tiles.add_child(instance)
	instance.global_position = Vector3(tile_size.x * column, 0, tile_size.y * row)

func _on_step_button_up() -> void:
	if current_map_step == null:
		clear()
		current_map_step = RandomMapGeneration.MapStep.new()
	
	if current_map_step.last_step:
		current_map_step = null
		clear()
		return
	
	var step_res = RandomMapGeneration.step_map(current_map_step)
	add_tile(step_res.tile, step_res.row, step_res.col)
	print(step_res.row, step_res.col)
	
