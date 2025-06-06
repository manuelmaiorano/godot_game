extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer
@export var detect_area: Area3D


func _ready() -> void:
	bt.blackboard.set_var(&"food_target", null)
	detect_area.area_entered.connect(_on_food_area_entered)
	
func _on_food_area_entered(area: Area3D) -> void:
	var current_target =  bt.blackboard.get_var(&"food_target") 
	if current_target == null:
		bt.blackboard.set_var(&"food_target", area.get_parent())
	elif area.global_position.distance_to(agent.global_position) < current_target.global_position.distance_to(agent.global_position):
		bt.blackboard.set_var(&"food_target", area.get_parent())

func try_set_nearby_food():
	var nearby_food = detect_area.get_overlapping_areas()
	if not nearby_food.is_empty():
		bt.blackboard.set_var(&"food_target", nearby_food[0].get_parent())
		return true
		
	return false
