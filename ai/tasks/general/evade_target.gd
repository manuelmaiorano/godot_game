@tool
extends BTAction


# Task parameters.
@export var move_anim_tree_state: StringName

var direction: Vector3 
var predator = null
var avoid_component = null

var time_to_turn_on_edge = 1

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "EvadeTarget"

func _setup() -> void:
	avoid_component = agent.find_child("AvoidEdgeComponent")

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state
	schedule_direction_updates()

func schedule_direction_updates():
	await agent.get_tree().create_timer(1).timeout
	var target = blackboard.get_var(&"target")
	if target == null:
		return
	direction = target.global_position - agent.global_position
	
# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var target = blackboard.get_var(&"target")
	if target == null or target.is_dead:
		return SUCCESS
	direction = avoid_component.update_direction(delta, direction)
	agent.move_along_direction(delta, direction)
	return RUNNING
