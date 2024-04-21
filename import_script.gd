@tool # Needed so it runs in editor.
extends EditorScenePostImport

var root = null
var door_script = null
# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	root = scene
	door_script = load("res://door.gd")
	print(root)
	iterate(scene)
	return scene # Remember to return the imported scene

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node: Node):
	if node != null:
		if node.name.contains("Door"):
			print_rich("Post-import: [b]%s[/b] -> [b]%s[/b]" % [node.name, "modified_" + node.name])
			var area = Area3D.new()
			var collision_shape = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			
			var animation_player : AnimationPlayer = AnimationPlayer.new()
			var animation: Animation = Animation.new()
			animation.add_track(Animation.TYPE_ROTATION_3D)
			
			animation.track_set_path(0, NodePath("%s:rotation" % node.find_child("door*").name))
			animation.track_insert_key(0, 0.0, Basis.from_euler(Vector3()))
			animation.track_insert_key(0, 1.0, Basis.from_euler(Vector3(0, deg_to_rad(120.0), 0)))
			#box_shape.size = 1.0
			
			collision_shape.shape = box_shape
			node.add_child(area)
			node.add_child(Node3D.new())
			area.add_child(collision_shape)
			area.set_owner(root)
			collision_shape.set_owner(root)
			
			node.add_child(animation_player)
			animation_player.set_owner(root)
			animation_player.name = "AnimationPlayer"
			var animation_library = AnimationLibrary.new()
			animation_library.add_animation("open", animation)
			animation_player.add_animation_library("", animation_library)
			
			node.set_script(door_script)
			
		for child in node.get_children():
			iterate(child)
