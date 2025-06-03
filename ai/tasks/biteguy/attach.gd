@tool
extends BTAction


# Task parameters.
@export var jump_animation_state: StringName
@export var follow_speed: float = 10
var target 

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Attach"
	
func _setup() -> void:
	pass

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = jump_animation_state
	agent.disable_collision()
	target = blackboard.get_var("target")
	
func _exit() -> void:
	agent.enable_collsion()

func _tick(delta: float) -> Status:
	if target == null:
		return FAILURE
	
	agent.global_position = agent.global_position.lerp(target.global_position + Vector3.UP * 5, delta * follow_speed)
	agent.global_basis = agent.global_basis.slerp(target.global_basis, delta * follow_speed)
	return RUNNING
