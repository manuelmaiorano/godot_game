@tool
extends BTAction


# Task parameters.
@export var move_anim_tree_state: StringName
@export var roll_anim_tree_state: StringName
@export var distance_to_start_rolling: float = 5

@export var distance_to_kill: float = 2

var target = null
var started_rolling = false

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "AttackTargetRollGuy"

func _enter() -> void:
	started_rolling = false
	target = blackboard.get_var("target")
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if target == null or target.is_dead:
		return FAILURE
	
	var distance_to_target = agent.global_position.distance_to(target.global_position)
	if distance_to_target < distance_to_start_rolling:
		if not started_rolling:
			agent.animation_tree["parameters/Transition/transition_request"] = roll_anim_tree_state
			agent.spikes()
			started_rolling = true
		agent.roll_towards(delta, target.global_position)
	else:
		agent.move_towards(delta, target.global_position)
		
	if distance_to_target < distance_to_kill:
		if target.entity_size == BaseAgent.EntitySize.SMALL:
			target.die()
			target.attach_to(agent)
		else:
			#agent.jump()
			blackboard.set_var("is_attached", true)
	return RUNNING
