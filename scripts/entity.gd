extends CharacterBody3D
@export var rotation_interpolate_spped = 10

@export var animation_tree: AnimationTree
@export var model: Node3D
@export var entity_stats: EntityStats


var orientation = Transform3D()
var root_motion = Transform3D()
var is_dead: bool = false


func _ready():
	# Pre-initialize orientation transform.
	orientation = model.global_transform
	orientation.origin = Vector3()
	
func rotate_towards_target(delta, target):
	var direction = global_position - target.global_position
	direction.y = 0
	
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(-direction.normalized(), Vector3.UP, true).basis.get_rotation_quaternion()
	
	
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * rotation_interpolate_spped))

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
	

	
func take_damage(attaker, damage):
	$EnemyBehaviourComponent.take_damage(attaker, damage)

func take_explosion_damage(velocity):
	$EnemyBehaviourComponent.take_explosion_damage(velocity)

func set_antagonists(value):
	$EnemyBehaviourComponent.set_antagonists(value)
