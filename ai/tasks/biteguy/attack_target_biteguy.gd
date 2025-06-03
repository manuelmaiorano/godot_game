@tool
extends BTAction


# Task parameters.
@export var move_anim_tree_state: StringName

@export var min_distance_to_eat: float
@export var min_distance_to_start_bite: float = 5.0

var target = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "AttackTargetBiteGuy"

func _enter() -> void:
	target = blackboard.get_var("target")
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if target == null or target.is_dead:
		return FAILURE
	
	var distance_to_target = agent.global_position.distance_to(target.global_position)
	if distance_to_target < min_distance_to_start_bite:
		agent.blend_bite(1.0)
		
	if distance_to_target < min_distance_to_eat:
		if target.entity_size == BaseAgent.EntitySize.SMALL:
			agent.blend_bite(0.0)
			target.attach_to(agent.target_to_attach_victim)
		else:
			agent.blend_bite(0.0)
			agent.jump()
			blackboard.set_var("is_attached", true)
		return SUCCESS
		
	agent.move_towards(delta, target.global_position)
	return RUNNING
