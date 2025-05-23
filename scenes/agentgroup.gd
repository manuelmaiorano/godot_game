extends Node

@export var blackboard_plan: BlackboardPlan
@export var group_names: Array[StringName]

var shared_scope: Blackboard

func _ready() -> void:
	shared_scope = Blackboard.new()
	shared_scope.set_var("global_targets",  {})
