@tool
extends BTAction


# Task parameters.
@export var eat_anim_tree_state: StringName

var target = null
var stat_component = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Eat"
	
func _setup() -> void:
	stat_component = agent.find_child("StatsComponent")
	

func _enter() -> void:
	target = blackboard.get_var(&"food_target")
	if eat_anim_tree_state:
		agent.animation_tree["parameters/Transition/transition_request"] = eat_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:

	if target == null or blackboard.get_var(&"is_hungry") == false:
		return SUCCESS
	var amount = stat_component.eat(delta)
	target.consume(amount)
	return RUNNING
