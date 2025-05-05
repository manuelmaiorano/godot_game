extends CharacterBody3D
const ROTATION_INTERPOLATE_SPEED = 10

@onready var state_chart: StateChart = %StateChart
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var model: Node3D = $dog

var target: Node3D



var orientation = Transform3D()
var root_motion = Transform3D()


func _ready():
	# Pre-initialize orientation transform.
	orientation = model.global_transform
	orientation.origin = Vector3()
	
func rotate_towards_target(delta):
	var direction = global_position - target.global_position
	direction.y = 0
	
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(-direction.normalized(), Vector3.UP, true).basis.get_rotation_quaternion()
	
	
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))

func apply_root_motion_to_velocity(delta):
	root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	orientation.origin = Vector3()

func apply_orientation_to_model():
	orientation = orientation.orthonormalized()
	model.global_transform.basis = orientation.basis

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == self:
		return
	target = body
	state_chart.send_event("go_to_target")

#IDLE
func _on_idle_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "idle"

func _on_idle_state_physics_processing(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	velocity += gravity * delta
	
	move_and_slide()


#WALK
func _on_walk_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "walk"

func _on_walk_state_physics_processing(delta: float) -> void:
	
	if global_position.distance_to(target.global_position) < 10:
		state_chart.send_event("attack")
		return
	
	rotate_towards_target(delta)
	apply_root_motion_to_velocity(delta)
	velocity += gravity * delta
	
	move_and_slide()
	apply_orientation_to_model()



#ATTACK
func _on_attack_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "attack"


func _on_attack_state_physics_processing(delta: float) -> void:
	
	apply_root_motion_to_velocity(delta)
	velocity += gravity * delta
	
	move_and_slide()
	apply_orientation_to_model()


func _on_attack_state_exited() -> void:
	animation_tree["parameters/Transition/transition_request"] = "idle"
