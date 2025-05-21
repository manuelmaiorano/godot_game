extends Node

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export var agent: CharacterBody3D
@export var model: Node3D
@export var animation_tree: AnimationTree
@export var detection_area: Area3D

@export var antagonist_groups: Array[StringName]
@export var hp_bar: HealthBar
@export var ragdoll_on_death: bool = false
@export var skeleton_modifier: PhysicalBoneSimulator3D
@export var hip_bone: PhysicalBone3D
@export var alive: LimboHSM
@export var has_hit_anim: bool = true
@export var can_ballista: bool = false

@onready var limbo_hsm: LimboHSM = %LimboHSM
@onready var falling: LimboState = %Falling
@onready var dead: LimboState = %Dead
@onready var hit: LimboState = %Hit
@onready var operating_ballista: LimboState = %OperatingBallista


var target: Node3D
var hp: float
var ballista: Node3D

func _ready() -> void:
	setup_hsm()
	hp = agent.entity_stats.max_hp
	if hp_bar:
		hp_bar.set_health(1)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	for area in agent.trigger_areas:
		area.body_entered.connect(_on_detection_area_body_entered)
	check_aggression()
	
		
func setup_hsm():
	agent.animation_tree.animation_finished.connect(on_animation_finished)
	falling.call_on_enter(_on_falling_state_entered)\
			.call_on_update(_on_falling_state_physics_processing)
	
	dead.call_on_enter(_on_dead_state_entered)
	
	hit.call_on_enter(_on_hit_state_entered)\
		.call_on_update(_on_hit_state_physics_processing)
	
	operating_ballista.call_on_enter(_on_ballista_state_entered)\
		.call_on_exit(_on_ballista_state_exited)
		
	
	limbo_hsm.add_transition(alive, dead, &"die")
	limbo_hsm.add_transition(alive, hit, &"hit")
	limbo_hsm.add_transition(alive, falling, &"falling")
	limbo_hsm.add_transition(alive, operating_ballista, &"ballista", func (): return target != null)
	
	limbo_hsm.add_transition(falling, alive, &"landed")
	limbo_hsm.add_transition(falling, dead, &"die")
	
	limbo_hsm.add_transition(hit, alive, hit.EVENT_FINISHED)
	
	
	limbo_hsm.initialize(agent)
	limbo_hsm.set_active(true)

func on_animation_finished(anim_name):
	if anim_name == "hit":
		limbo_hsm.dispatch(hit.EVENT_FINISHED)
	 
	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == self:
		return
	for group in body.get_groups():
		if antagonist_groups.find(group) > -1:
			target = body
			limbo_hsm.dispatch(&"go_to_target")
			return

func reduce_health(damage):
	hp = clamp(hp - damage, 0, hp)
	if hp_bar:
		hp_bar.set_health(hp/agent.entity_stats.max_hp)
	

func take_damage(attaker, damage):
	var body = attaker
	reduce_health(damage)
	
	if hp <= 0:
		limbo_hsm.dispatch(&"die")
		return true
	
	limbo_hsm.dispatch(&"hit")
		
	if check_if_antagonist(body):
		target = body
		limbo_hsm.dispatch(&"go_to_target")
		return

func take_explosion_damage(velocity, damage):
	reduce_health(damage)
	if hp <= 0:
		limbo_hsm.dispatch(&"die")
		if ragdoll_on_death:
			hip_bone.apply_central_impulse(velocity)

func close_to_ballista(which):
	if not can_ballista:
		return
		
	ballista = which
	limbo_hsm.dispatch(&"ballista")
	

func set_antagonists(value):
	antagonist_groups = value
	limbo_hsm.dispatch(&"deaggro")

	call_deferred("check_aggression")

	
func check_aggression():
	for body in detection_area.get_overlapping_bodies():
		if check_if_antagonist(body):
			target = body
			limbo_hsm.dispatch(&"go_to_target")
			
			return
	
func check_if_antagonist(body):
	for group in body.get_groups():
		if antagonist_groups.find(group) > -1:
			return true
	return false

#DEAD
func _on_dead_state_entered() -> void:
	reduce_health(hp)
	agent.is_dead = true
	SignalBus.EnemyKilled.emit(agent.entity_stats.points)
	if ragdoll_on_death:
		animation_tree.active = false
		skeleton_modifier.active = true
		skeleton_modifier.physical_bones_start_simulation()
	else:
		agent.queue_free()

#HIT
func _on_hit_state_entered() -> void:
	if has_hit_anim:
		agent.animation_tree["parameters/Transition/transition_request"] = "hit"



func _on_hit_state_physics_processing(delta: float) -> void:
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()

#FALLING

var max_velocity = 0
func _on_falling_state_entered() -> void:
	max_velocity = 0
	
func _on_falling_state_physics_processing(delta: float) -> void:
	if agent.is_on_floor():
		if max_velocity <= 15:
			limbo_hsm.dispatch(&"landed")
		else:
			limbo_hsm.dispatch(&"die")
		return
	
	if abs(agent.velocity.y) > max_velocity:
		max_velocity = abs(agent.velocity.y)
	
	agent.velocity += gravity * delta
	agent.move_and_slide()


#Ballista
func fire_ballista():
	if ballista == null:
		return
	
	ballista.fire()


func aim_target(delta):
	var angle_diff = ballista.aim_at(target, delta)
	operating_ballista.blackboard.set_var(&"angle_to_target_deg", rad_to_deg(angle_diff))
	agent.global_transform = ballista.operator_position.global_transform
	
func _on_ballista_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"
	ballista.shooter = agent
	
	
func _on_ballista_state_exited() -> void:
	ballista.shooter = null
