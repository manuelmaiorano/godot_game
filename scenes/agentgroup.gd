extends Node

@export var blackboard_plan: BlackboardPlan
@export var group_names: Array[StringName]

var shared_scope: Blackboard

func _ready() -> void:
	shared_scope = Blackboard.new()
	shared_scope.set_var("global_targets",  {})
	
func _process(delta: float) -> void:
	var dic = {}
	DebugDraw2D.set_text("shared", shared_scope.get_var("global_targets").keys())
