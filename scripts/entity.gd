extends CharacterBody3D
class_name BaseAgent

@export var rotation_interpolate_spped = 10
@export var animation_tree: AnimationTree
@export var model: Node3D
@export var entity_stats: EntityStats
@export var trigger_areas: Array[Area3D]
@export var hp_bar: HealthBar
@export var ragdoll_on_death: bool = false
@export var skeleton_modifier: PhysicalBoneSimulator3D
@export var hip_bone: PhysicalBone3D
@export var antagonist_groups: Array[StringName]
@export var patrol_points: Array[Node3D]
@export var vision_cone: Node3D
@export var debug_mode: bool = false
@export var entity_size: EntitySize = EntitySize.SMALL
@export var food_chain_idx = 0

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var orientation = Transform3D()
var root_motion = Transform3D()

var hp: float
var is_dead: bool = false


signal hit(by_who: BaseAgent)
signal target_spotted
signal target_list_changed(target_list: Dictionary[Node3D, TargetInfo])
signal dead
signal antagonist_changed
signal took_damage(hp_percentage_now)

enum EntitySize {
	SMALL,
	BIG
}


class TargetInfo:
	var visible: bool
	var last_known_position: Vector3
	var last_time_seen: int

var target_list: Dictionary[Node3D, TargetInfo]


func _ready():
	# Pre-initialize orientation transform.

	hp = entity_stats.max_hp
	if hp_bar:
		hp_bar.set_health(1)
	orientation = model.global_transform
	orientation.origin = Vector3()

	if vision_cone:
		vision_cone.body_sighted.connect(_on_body_sighted)
		vision_cone.body_hidden.connect(_on_body_hidden)
	for area in trigger_areas:
		area.body_entered.connect(_on_body_sighted)
		area.body_exited.connect(_on_body_hidden)


func _on_body_sighted(body: Node3D) -> void:
	if body == self or body.is_dead:
		return
	
	if not check_if_antagonist(body):
		return
	
	if not target_list.has(body):
		var info = TargetInfo.new()
		info.visible = true
		target_list[body] = info
	else:
		target_list[body].visible = true
	
	target_list_changed.emit(target_list)

func _on_body_hidden(body: Node3D) -> void:
	if body == self or body.is_dead:
		return
		
	if not check_if_antagonist(body):
		return
		
	#SignalBus.PauseGameDebug.emit()
	
	if not target_list.has(body):
		var info = TargetInfo.new()
		info.visible = false
		info.last_known_position = body.global_position
		info.last_time_seen = Time.get_ticks_msec()
		target_list[body] = info
	else:
		target_list[body].visible = false
		target_list[body].last_known_position = body.global_position
		target_list[body].last_time_seen = Time.get_ticks_msec()
	
	target_list_changed.emit(target_list)

func rotate_towards_point(delta, point, run_away = false):
	var direction: Vector3 = global_position - point
	direction.y = 0
	
	if run_away:
		direction *= -1
		
	if direction.is_zero_approx():
		return
	
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(-direction.normalized(), Vector3.UP, true).basis.get_rotation_quaternion()
	
	
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * rotation_interpolate_spped))
	
func rotate_towards_target(delta, target, run_away = false):
	rotate_towards_point(delta, target.global_position, run_away)


func rotate_away_from_target(delta, target):
	rotate_towards_target(delta, target, true)

func apply_root_motion_to_velocity(delta, use_y = false):
	root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	if use_y:
		velocity.y = h_velocity.y
	orientation.origin = Vector3()

func apply_orientation_to_model():
	orientation = orientation.orthonormalized()
	model.global_transform.basis = orientation.basis
	
func apply_lateral_velocity(speed):
	var lateral_velocity = model.global_basis.z * speed
	velocity.x = lateral_velocity.x
	velocity.z = lateral_velocity.z

func apply_gravity(delta):
	velocity += gravity * delta

func move_towards(delta, point, use_root_motion=false, is_running=true):
	rotate_towards_point(delta, point)
	
	var speed
	if is_running:
		speed = entity_stats.run_speed
	else:
		speed = entity_stats.walk_speed
		
	if use_root_motion:
		apply_root_motion_to_velocity(delta)
	else:
		apply_lateral_velocity(speed)
	
	apply_gravity(delta)
	move_and_slide()
	apply_orientation_to_model()

func move_along_direction(delta, direction, use_root_motion=false, is_running=true):
	rotate_towards_point(delta, global_position - direction)
	
	var speed
	if is_running:
		speed = entity_stats.run_speed
	else:
		speed = entity_stats.walk_speed
		
	if use_root_motion:
		apply_root_motion_to_velocity(delta)
	else:
		apply_lateral_velocity(speed)
	
	apply_gravity(delta)
	move_and_slide()
	apply_orientation_to_model()
	
func reduce_health(damage):
	hp = clamp(hp - damage, 0, hp)
	if hp_bar:
		hp_bar.set_health(hp/entity_stats.max_hp)
	took_damage.emit(hp/entity_stats.max_hp)
	

func take_damage(attaker, damage):
	var body = attaker
	reduce_health(damage)
	
	if hp <= 0:
		die()
		return true
		
	if check_if_antagonist(attaker):
		hit.emit(attaker)
	print("%s attacked %s" % [attaker.name, self.name])

func take_explosion_damage(velocity, damage):
	reduce_health(damage)
	if hp <= 0:
		die()
		if ragdoll_on_death:
			hip_bone.apply_central_impulse(velocity)
			
func die():
	print("%s died" % name)
	reduce_health(hp)
	is_dead = true
	dead.emit()
	if not is_in_group("player"):
		SignalBus.EnemyKilled.emit(entity_stats.points)
	if ragdoll_on_death:
		ragdoll()
	disable_collision()
	disable_ai()
	
func attach_to(target):
	disable_collision()
	disable_ai()
	reparent(target)


func ragdoll():
	animation_tree.active = false
	skeleton_modifier.active = true
	skeleton_modifier.physical_bones_start_simulation()
	

#func set_antagonists(value):
	#antagonist_groups = value
	#target_list = {}
	#for body in vision_cone.get_visible_bodies():
		#if body == self or body.is_dead:
			#return
	#
		#if not check_if_antagonist(body):
			#return
		#var info = TargetInfo.new()
		#info.visible = true
		#target_list[body] = info
		#
	#target_list_changed.emit(target_list)

func set_antagonists(value):
	pass

#func check_if_antagonist(body):
	#for group in body.get_groups():
		#if antagonist_groups.find(group) > -1:
			#return true
	#return false

func check_if_antagonist(body):
	if body.get_groups()[0] != self.get_groups()[0]:
		return true
	return false
	
func check_if_prey(other: BaseAgent):
	return food_chain_idx < other.food_chain_idx

func check_if_predator(other: BaseAgent):
	return food_chain_idx > other.food_chain_idx
	
func disable_collision():
	$CollisionShape3D.disabled = true
	

func enable_collision():
	$CollisionShape3D.disabled = true


func disable_ai():
	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)
