extends LimboHSM

@export var character: BaseAgent
@onready var dead: LimboState = %Dead
@onready var alive: LimboHSM = %Alive
@onready var onground: LimboHSM = %Onground
@onready var falling: LimboState = %Falling
@onready var attack: BTState = %Attack
@onready var patrol: BTState = %Patrol


func _ready() -> void:

	onground.active_state_changed.connect(on_state_cahnged)
	dead.call_on_enter(func (): character.die())
	character.dead.connect(func(): dispatch(&"dead"))
	add_transition(alive, dead, &"dead")
	
	alive.add_transition(onground, falling, &"fall", func (): character.velocity.y < 10)
	alive.add_transition(falling, onground, &"landed")
	onground.call_on_update(func (delta): if not character.is_on_floor(): dispatch(&"fall"))
	
	attack.call_on_exit(func(): onground.blackboard.set_var("target", null))
	
	character.hit.connect(on_hit)
	character.target_list_changed.connect(on_target_list_changed)
	
	onground.add_transition(patrol, attack, &"target_spotted")
	onground.add_transition(attack, patrol, &"target_lost")
	
	patrol.call_on_enter(on_target_list_changed.bind(character.target_list))
	
	initialize(character)
	set_active(true)
	
	
	blackboard.set_parent(Agentgroup.shared_scope)
	
func on_state_cahnged(current, _prev): 
	if character.debug_mode: 
		%TextDebug.text = current.name


func on_hit(who):
	if not character.check_if_antagonist(who):
		return
		
	if character.global_position.distance_to(who.global_position) < 5:
		
		onground.blackboard.set_var("target", who)
		dispatch(&"target_spotted")
	else:
		onground.blackboard.set_var("last_known_target_position", who.global_position)
		dispatch(&"investigate")

func on_target_list_changed(target_list: Dictionary[Node3D, BaseAgent.TargetInfo]):
	var current_target = onground.blackboard.get_var("target")
	if current_target == null or current_target.is_dead:
		var new_target = get_new_target()
		if new_target == null:
			return
			
		onground.blackboard.set_var("target", new_target)
		var global_targets = Agentgroup.shared_scope.get_var("global_targets")
		global_targets[new_target] = true
		
		dispatch( &"target_spotted")
		return
	#
	#if not character.target_list[current_target].visible or not character.target_list.has(current_target):
		#
		#var distance_to_target = character.global_position.distance_to(current_target.global_position)
		#if distance_to_target < 10:
			#return
			#
		#onground.blackboard.set_var("target", null)
		#var global_targets = Agentgroup.shared_scope.get_var("global_targets") as Dictionary
		#global_targets.erase(current_target)
		#
		#var last_known_position = character.target_list[current_target].last_known_position
		#onground.blackboard.set_var("last_known_target_position", last_known_position)
#
		#dispatch(&"investigate")
		#return
		
func get_new_target():
	var target_list = character.target_list
	var global_targets = Agentgroup.shared_scope.get_var("global_targets") as Dictionary
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
	
