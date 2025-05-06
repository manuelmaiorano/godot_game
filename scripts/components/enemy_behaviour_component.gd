extends Node

@onready var state_chart: StateChart = %StateChart
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export var agent: CharacterBody3D
@export var model: Node3D
@export var animation_tree: AnimationTree
@export var detection_area: Area3D

@export var distance_to_attack: float
@export var antagonist_groups: Array[StringName]

var target: Node3D

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == self:
		return
	for group in body.get_groups():
		if antagonist_groups.find(group) > -1:
			target = body
			state_chart.send_event("go_to_target")
			return
	

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
	agent.animation_tree["parameters/Transition/transition_request"] = "attack"


func _on_attack_state_physics_processing(delta: float) -> void:
	agent.rotate_towards_target(delta, target)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()


func _on_attack_state_exited() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"
