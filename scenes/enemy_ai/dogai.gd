extends LimboHSM

@export var character: BaseAgent
@onready var dead: LimboState = %Dead
@onready var alive: LimboHSM = %Alive
@onready var onground: LimboHSM = %Onground
@onready var falling: LimboState = %Falling
@onready var attack: BTState = %Attack
@onready var patrol: BTState = %Patrol
@onready var investigate: BTState = %Investigate


func _ready() -> void:

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
	onground.add_transition(patrol, investigate, &"investigate")
	
	onground.add_transition(investigate, attack, &"target_spotted")
	onground.add_transition(investigate, patrol, &"investigation_complete")
	
	onground.add_transition(attack, investigate, &"investigate")
	onground.add_transition(attack, patrol, &"target_lost")
	
	initialize(character)
	set_active(true)
	
	
	blackboard.set_parent(Agentgroup.shared_scope)

func on_hit(who):
	var current_target = onground.blackboard.get_var("target")
	if current_target == null:
		onground.blackboard.set_var("last_known_target_position", who.global_position)
		dispatch(&"investigate")
		return

func on_target_list_changed(target_list: Dictionary[Node3D, BaseAgent.TargetInfo]):
	var current_target = onground.blackboard.get_var("target")
	if current_target == null:
		var new_target = character.get_first_visible_target()
		if new_target == null:
			return
		onground.blackboard.set_var("target", new_target)
		var global_targets = Agentgroup.shared_scope.get_var("global_targets")
		global_targets[new_target] = true
		dispatch( &"target_spotted")
		return
	
	if not character.target_list[current_target].visible:
		onground.blackboard.set_var("target", null)
		var global_targets = Agentgroup.shared_scope.get_var("global_targets") as Dictionary
		global_targets.erase(current_target)
		onground.blackboard.set_var("last_known_target_position", character.target_list[current_target].last_known_position)
		dispatch(&"investigate")
		return
