extends CharacterBody3D

const ROTATION_INTERPOLATE_SPEED = 10

@export var mouse_sensitivity:float = 500
@export var clamp_pitch_rotation:float = 80
@export var move_speed: float = 10
@export var antagonist_groups: Array[StringName]


@onready var camera_3d: Camera3D = %Camera3D
@onready var pitch:Node3D = %Pitch
@onready var yaw:Node3D =  %Yaw
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var camera_animation: AnimationPlayer = %CameraAnimation

@onready var state_chart: StateChart = %StateChart
@onready var shoot_from: Marker3D = %ShootFrom


var orientation = Transform3D()
var root_motion = Transform3D()
var is_dead = false

var active_item: Item = null

func _ready():
	# Pre-initialize orientation transform.
	orientation = $chessinggame.global_transform
	orientation.origin = Vector3()
	SignalBus.InventoryItemSelected.connect(on_inventory_item_selected)

func _input(event:InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
		
	var mouse_movement:Vector2 = event.relative / mouse_sensitivity * PI
	
	pitch.rotation_degrees.x = clamp(pitch.rotation_degrees.x - rad_to_deg(mouse_movement.y), -clamp_pitch_rotation, clamp_pitch_rotation )
	yaw.rotate_y(-mouse_movement.x )

func on_inventory_item_selected(item: Item):
	active_item = item


### IDLE

func _on_idle_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "idle"
	
func _on_idle_state_physics_processing(delta: float) -> void:
	var movement_direction:Vector2 = Input.get_vector("backward", "forward", "left", "right")
	if not movement_direction.is_zero_approx():
		state_chart.send_event("running")
	
	
	velocity.x = 0
	velocity.z = 0
	velocity += gravity * delta
	
	move_and_slide()


func _on_idle_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim"):
		camera_animation.play("zoom_in")
		state_chart.send_event("aim")

### RUN
func _on_run_state_physics_processing(delta: float) -> void:
	var movement_direction:Vector2 = Input.get_vector("backward", "forward", "left", "right")
	if movement_direction.is_zero_approx():
		state_chart.send_event("no_input")
	
	if not is_on_floor():
		state_chart.send_event("falling")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_chart.send_event("jump")
		return
		
	var camera_basis : Basis = camera_3d.global_basis
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	var target = - camera_x * movement_direction.y + camera_z * movement_direction.x
	if target.is_zero_approx():
		return
	
	
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))


	root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	
	velocity += gravity * delta
	
	move_and_slide()
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.
	
	$chessinggame.global_transform.basis = orientation.basis


func _on_run_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "run"
	
### FALL

func _on_falling_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "fall"
	
func _on_falling_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("landed")
		return
		
	velocity += gravity * delta
	
	move_and_slide()

### JUMP


func _on_jumping_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "jump"


func _on_jumping_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("landed")
		
	root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	#velocity.x = h_velocity.x
	#velocity.z = h_velocity.z
	velocity.y = h_velocity.y
	#velocity += gravity * delta
	
	move_and_slide()
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.
	
	$chessinggame.global_transform.basis = orientation.basis

### AIM


func _on_aiming_state_physics_processing(delta: float) -> void:
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = yaw.basis.get_rotation_quaternion()
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	velocity.x = 0
	velocity.z = 0
	
	velocity += gravity * delta
	
	move_and_slide()
	
	
	$chessinggame.global_transform.basis = orientation.basis
	$chessinggame.rotate_y(deg_to_rad(180))

func get_target_collider():
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	
	var ch_pos = crosshair.position + crosshair.size * 0.5
	var ray_from = camera_3d.project_ray_origin(ch_pos)
	var ray_dir = camera_3d.project_ray_normal(ch_pos)
		
	var col = get_parent().get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		ray_from, ray_from + ray_dir * 1000, collision_mask))
	
	if col.is_empty():
		return null
	return col.collider
	
func get_target_position():
	
	var target_position
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	
	var ch_pos = crosshair.position + crosshair.size * 0.5
	var ray_from = camera_3d.project_ray_origin(ch_pos)
	var ray_dir = camera_3d.project_ray_normal(ch_pos)
		
	var col = get_parent().get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		ray_from, ray_from + ray_dir * 1000, collision_mask))
		
	if col.is_empty():
		target_position = ray_from + ray_dir * 1000
	else:
		target_position = col.position
	
	return target_position

func _on_aiming_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		
		if active_item.name == &"pew":
			var instance = preload("res://scenes/bullet.tscn").instantiate()
			var start_position = shoot_from.global_position
			var target_position = get_target_position()
			
			get_parent().add_child(instance)
			instance.global_position = start_position
			instance.shooter = self
			instance.velocity = (target_position - start_position).normalized() * Globals.bullet_velocity
		
		if active_item.name == &"trap":
			var instance = preload("res://scenes/trap.tscn").instantiate()
			
			get_parent().add_child(instance)
			instance.global_position = get_target_position()
		
		if active_item.name == &"branch":
			var collider: Node = get_target_collider()
			if collider:
				for group in collider.get_groups():
					if antagonist_groups.find(group) > -1:
						collider.set_antagonists(antagonist_groups)
						return
			
			
		
		
	if Input.is_action_just_pressed("aim"):
		camera_animation.play_backwards("zoom_in")
		state_chart.send_event("stop_aim")


func _on_aiming_state_entered() -> void:
	get_tree().get_first_node_in_group("crosshair").show()


func _on_aiming_state_exited() -> void:
	get_tree().get_first_node_in_group("crosshair").hide()
