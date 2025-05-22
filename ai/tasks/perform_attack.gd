@tool
extends BTAction


# Task parameters.
@export var attack_anim_tree_state: StringName
@export var final_attack_anim_name: StringName

var last_attack_animation_played = false
var target

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "PerformAttack"
	
func _setup() -> void:
	agent.animation_tree.animation_finished.connect(on_finished_animation)

func _enter() -> void:
	target = blackboard.get_var("target")
	last_attack_animation_played = false
	agent.animation_tree["parameters/Transition/transition_request"] = attack_anim_tree_state
	
func on_finished_animation(name):
	if name == final_attack_anim_name: 
		last_attack_animation_played = true
	
	
# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if target == null:
		return FAILURE
	if last_attack_animation_played:
		return SUCCESS
	agent.rotate_towards_target(delta, target)
	agent.apply_root_motion_to_velocity(delta, true)
	#agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
