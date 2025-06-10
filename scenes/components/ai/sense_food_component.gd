extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer
@export var detect_area: Area3D


func _ready() -> void:
	bt.blackboard.set_var(&"food_target", null)
	detect_area.area_entered.connect(_on_food_area_entered)
	schedule_check_nearby_food(2)

func schedule_check_nearby_food(timeout):
	while true:
		await agent.get_tree().create_timer(timeout).timeout
		var current_target =  bt.blackboard.get_var(&"food_target") 
		if current_target == null:
			try_set_nearby_food()
	
func _on_food_area_entered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("food"):
		return
	var current_target =  bt.blackboard.get_var(&"food_target") 
	if current_target == null:
		bt.blackboard.set_var(&"food_target", area.get_parent())
	elif area.global_position.distance_to(agent.global_position) < current_target.global_position.distance_to(agent.global_position):
		bt.blackboard.set_var(&"food_target", area.get_parent())

func try_set_nearby_food():
	var nearby_areas = detect_area.get_overlapping_areas()
	for area in nearby_areas:
		if area.get_parent().is_in_group("food"):
			bt.blackboard.set_var(&"food_target", area.get_parent())
			return true
		
	return false
