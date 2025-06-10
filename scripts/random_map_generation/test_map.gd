@tool
extends EditorScript


func  _run() -> void:
	var map_scene = load("res://scripts/random_map_generation/randomMapGeneration.tscn").instantiate()
	var map = map_scene.generate_map()
	for y in map.size():
		var s = ""
		for x in map[y]:
			s = s + x.debug_str
		print(s)
		
