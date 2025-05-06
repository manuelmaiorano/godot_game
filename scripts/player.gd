extends CharacterBody3D

const ROTATION_INTERPOLATE_SPEED = 10

@export var mouse_sensitivity:float = 500
@export var clamp_pitch_rotation:float = 80
@export var move_speed: float = 10


@onready var camera_3d: Camera3D = %Camera3D
@onready var pitch:Node3D = %Pitch
@onready var yaw:Node3D =  %Yaw
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var camera_animation: AnimationPlayer = %CameraAnimation

@onready var state_chart: StateChart = %StateChart


var orientation = Transform3D()
var root_motion = Transform3D()


func _ready():
	# Pre-initialize orientation transform.
	orientation = $chessinggame.global_transform
	orientation.origin = Vector3()

func _input(event:InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
		
	var mouse_movement:Vector2 = event.relative / mouse_sensitivity * PI
	
	pitch.rotation_degrees.x = clamp(pitch.rotation_degrees.x - rad_to_deg(mouse_movement.y), -clamp_pitch_rotation, clamp_pitch_rotation )
	yaw.rotate_y(-mouse_movement.x )

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim"):
		camera_animation.play("zoom_in")

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
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()

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
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
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
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.
	
	$chessinggame.global_transform.basis = orientation.basis
