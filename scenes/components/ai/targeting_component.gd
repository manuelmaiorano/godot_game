extends Node

enum TARGET_SELECTION_MODE {PICK_FIRST, PICK_RANDOM, PICK_UNTARGETED}

@export var agent: BaseAgent
@export var bt: BTPlayer
@export var target_selection_mode: TARGET_SELECTION_MODE
@export var min_distance_to_keep_target_after_not_visible = 5.0


func _ready() -> void:
	agent.target_list_changed.connect(on_target_list_changed)
	bt.blackboard.set_var("target", null)
	bt.blackboard.set_var("last_known_target_position", null)
	bt.blackboard.set_var("last_time_seen", null)
	
	
func on_target_list_changed(target_list: Dictionary[Node3D, BaseAgent.TargetInfo]):
	var current_target = bt.blackboard.get_var("target")
	
	if current_target == null or current_target.is_dead:
		var new_target = pick_new_target(target_list)
		if new_target == null:
			return
		bt.blackboard.set_var("target", new_target)
		WorldState.shared_scope.get_var("global_targets").append(new_target)
		return
	
	if not target_list.has(current_target) or target_list[current_target].visible == false:
		if agent.global_position.distance_to(current_target.global_position) < min_distance_to_keep_target_after_not_visible:
			return
		
		WorldState.shared_scope.get_var("global_targets").erase(current_target)
		if not target_list.has(current_target):
			return
		
		bt.blackboard.set_var("target", null)
		bt.blackboard.set_var("last_known_target_position", target_list[current_target].last_known_position)
		bt.blackboard.set_var("last_time_seen", target_list[current_target].last_time_seen)

func pick_new_target(target_list):
	match target_selection_mode:
		TARGET_SELECTION_MODE.PICK_FIRST:
			return pick_first(target_list)
		TARGET_SELECTION_MODE.PICK_RANDOM:
			return pick_random(target_list)
		TARGET_SELECTION_MODE.PICK_UNTARGETED:
			return pick_first_non_targeted(target_list)


func pick_first(target_list:  Dictionary[Node3D, BaseAgent.TargetInfo]):
	for target in target_list.keys():
		if target.is_dead:
			continue
		if target_list[target].visible == false:
			return
		
		return target
	return null
	
func pick_random(target_list:  Dictionary[Node3D, BaseAgent.TargetInfo]):
	return target_list.keys().filter(func (x): return not x.is_dead and target_list[x].visible ).pick_random()
	
func pick_first_non_targeted(target_list:  Dictionary[Node3D, BaseAgent.TargetInfo]):
	var global_targets = WorldState.shared_scope.get_var("global_targets") as Array
	var already_targeted = []
	
	for target in target_list.keys():
		if target.is_dead:
			continue
		if target_list[target].visible == false:
			return
		if global_targets.has(target):
			already_targeted.append(target)
			continue
		return target
		
	if not already_targeted.is_empty():
		return already_targeted[0]
	return null
