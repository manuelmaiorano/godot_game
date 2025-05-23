extends Node3D
class_name VisionSystem

signal body_sighted(body)
signal body_hidden(body)

@export_flags_3d_physics  var collision_mask: int
@export_flags_3d_physics  var collision_environment_mask: int
@export var vision_test_ignore_bodies : Array[PhysicsBody3D]
@export var max_body_count = 5
@export var debug_mode = false


@onready var area_3d: Area3D = %Area3D

var body_list_visibility: Dictionary[Node3D, bool] = {}


func _ready() -> void:
	area_3d.collision_mask = collision_mask
	if not debug_mode:
		set_process(false)

func _physics_process(delta: float) -> void:
	check_visibility()
	
func _process(delta: float) -> void:
	DebugDraw2D.set_text("Can See", body_list_visibility)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body_list_visibility.size() > max_body_count:
		return
		
	var now_visible = check_visible(body)
	body_list_visibility[body] = now_visible
	if now_visible:
		body_sighted.emit(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	body_list_visibility.erase(body)
	body_hidden.emit(body)
	

func check_visibility():
	for body in body_list_visibility.keys():
		var past_visible = body_list_visibility[body]
		var now_visible = check_visible(body)
		if not now_visible and past_visible:
			body_hidden.emit(body)
			if debug_mode:
				print_rich("[color=red][b]body_hidden[/b][/color]")

		if not past_visible and now_visible:
			body_sighted.emit(body)
			if debug_mode:
				print_rich("[color=green][b]body_sighted[/b][/color]")
			
		body_list_visibility[body] = now_visible
		

func check_visible(body: PhysicsBody3D):

	var raycast_collision_mask := collision_mask | collision_environment_mask

	var space_state := get_world_3d().direct_space_state
	var from := global_position
	var to = body.global_position + Vector3.UP

	var exclude_bodies := vision_test_ignore_bodies\
		.filter(func(x: PhysicsBody3D) -> bool: return is_instance_valid(x))\
		.map(func(x: PhysicsBody3D) -> RID: return x.get_rid())
	var query := PhysicsRayQueryParameters3D.create(
		from,
		to,
		raycast_collision_mask,
		exclude_bodies
	)
	var result := space_state.intersect_ray(query)
	
	if result.has("collider"):
		if result.collider == body:
			if debug_mode:
				DebugDraw3D.draw_line(from, to, Color.GREEN)
			return true
		else:
			if debug_mode:
				DebugDraw3D.draw_line(from, to, Color.RED)
			return false
	else:
		if debug_mode:
			DebugDraw3D.draw_line(from, to, Color.RED)
		return false
	
