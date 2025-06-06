extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer


func _ready() -> void:
	bt.blackboard.set_var(&"food_target", null)
	


func _on_area_3d_area_entered(area: Area3D) -> void:
	var current_target =  bt.blackboard.get_var(&"food_target") 
	if current_target == null:
		bt.blackboard.set_var(&"food_target", area.get_parent())
	elif area.global_position.distance_to(agent.global_position) < current_target.global_position.distance_to(agent.global_position):
		bt.blackboard.set_var(&"food_target", area.get_parent())
