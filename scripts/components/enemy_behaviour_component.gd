extends Node

@onready var state_chart: StateChart = %StateChart
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export var agent: CharacterBody3D
@export var model: Node3D
@export var animation_tree: AnimationTree
@export var detection_area: Area3D

@export var distance_to_attack: float
@export var antagonist_groups: Array[StringName]
@export var hp_bar: HealthBar
@export var ragdoll_on_death: bool = false
@export var skeleton_modifier: PhysicalBoneSimulator3D
@export var hip_bone: PhysicalBone3D
@export var can_dodge: bool = false

var target: Node3D
var hp: float

func _ready() -> void:
	
	hp = agent.entity_stats.max_hp
	if hp_bar:
		hp_bar.set_health(1)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == self:
		return
	for group in body.get_groups():
		if antagonist_groups.find(group) > -1:
			target = body
			state_chart.send_event("go_to_target")
			return

func reduce_health(damage):
	hp = clamp(hp - damage, 0, hp)
	if hp_bar:
		hp_bar.set_health(hp/agent.entity_stats.max_hp)
	

func take_damage(attaker, damage):
	var body = attaker
	reduce_health(damage)
	
	if hp <= 0:
		state_chart.send_event("die")
		return true
	
	state_chart.send_event("hit")
		
	if check_if_antagonist(body):
		target = body
		state_chart.send_event("go_to_target")
		return

func take_explosion_damage(velocity):
	reduce_health(hp)
	state_chart.send_event("die")
	if ragdoll_on_death:
		hip_bone.apply_central_impulse(velocity)

func set_antagonists(value):
	antagonist_groups = value
	state_chart.send_event("deaggro")
	call_deferred("check_aggression")

	
func check_aggression():
	for body in detection_area.get_overlapping_bodies():
		if check_if_antagonist(body):
			target = body
			state_chart.send_event("go_to_target")
			return
	
func check_if_antagonist(body):
	for group in body.get_groups():
		if antagonist_groups.find(group) > -1:
			return true
	return false

#IDLE
func _on_idle_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"

func _on_idle_state_physics_processing(delta: float) -> void:
	agent.velocity.x = 0
	agent.velocity.z = 0
	agent.velocity += gravity * delta
	
	agent.move_and_slide()


#WALK
func _on_walk_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "walk"

func _on_walk_state_physics_processing(delta: float) -> void:
	if target == null or target.is_dead:
		state_chart.send_event("stop_moving")
		return
		
	if agent.global_position.distance_to(target.global_position) < distance_to_attack:
		state_chart.send_event("attack")
		return
	
	agent.rotate_towards_target(delta, target)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()



#ATTACK
func _on_attack_state_entered() -> void:
	var should_dodge = false
	if can_dodge:
		should_dodge = randf() > 0.5
	if should_dodge:
		agent.animation_tree["parameters/Transition/transition_request"] = "dodge"
	else:
		agent.animation_tree["parameters/Transition/transition_request"] = "attack"


func _on_attack_state_physics_processing(delta: float) -> void:
	if target == null  or target.is_dead:
		state_chart.send_event("deaggro")
		return
	agent.rotate_towards_target(delta, target)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()


func _on_attack_state_exited() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"

#DEAD
func _on_dead_state_entered() -> void:
	agent.is_dead = true
	if ragdoll_on_death:
		animation_tree.active = false
		skeleton_modifier.active = true
		skeleton_modifier.physical_bones_start_simulation()
	else:
		agent.queue_free()

#HIT
func _on_hit_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "hit"



func _on_hit_state_physics_processing(delta: float) -> void:
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
