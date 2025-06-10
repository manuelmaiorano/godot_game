extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer
@export var detect_area: Area3D


func _ready() -> void:
	bt.blackboard.set_var(&"patrol_points", [])
	detect_area.area_entered.connect(_on_area_entered)

	
func _on_area_entered(area: Area3D) -> void:
	if not area.get_parent().is_in_group("patrol_point"):
		return
	var current_patrol_points = bt.blackboard.get_var(&"patrol_points") as Array
	if not current_patrol_points.has(area.get_parent()):
		current_patrol_points.append(area.get_parent())
