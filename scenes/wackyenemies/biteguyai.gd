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
	
	character.hit.connect(on_hit)
	
	character.target_list_changed.connect(on_target_list_changed)
	onground.add_transition(patrol, attack, &"target_spotted")
	onground.add_transition(patrol, investigate, &"investigate")
	
	onground.add_transition(investigate, attack, &"target_spotted")
	onground.add_transition(investigate, patrol, &"investigation_complete")
	
	onground.add_transition(attack, investigate, &"investigate")
	onground.add_transition(attack, patrol, &"target_lost")
	
	patrol.call_on_enter(on_target_list_changed.bind(character.target_list))
	
	initialize(character)
	set_active(true)

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
		var new_target = AiUtils.pick_target(target_list)
		if new_target == null:
			return
			
		AiUtils.set_target(onground.blackboard, new_target)
		
		dispatch( &"target_spotted")
		return
	
	if not character.target_list[current_target].visible or not character.target_list.has(current_target):
		
		var distance_to_target = character.global_position.distance_to(current_target.global_position)
		if distance_to_target < 10:
			return
			
		AiUtils.reset_target(onground.blackboard, current_target)
		
		var last_known_position = character.target_list[current_target].last_known_position
		onground.blackboard.set_var("last_known_target_position", last_known_position)

		dispatch(&"investigate")
		return
