extends LimboHSM

@export var character: BaseAgent
@onready var dead: LimboState = %Dead
@onready var alive: LimboHSM = %Alive
@onready var not_hit: LimboHSM = %NotHit
@onready var onground: LimboHSM = %Onground
@onready var falling: LimboState = %Falling
@onready var hit_reaction: BTState = %HitReaction
@onready var attack: BTState = %Attack
@onready var patrol: BTState = %Patrol


func _ready() -> void:

	dead.call_on_enter(func (): character.die())
	character.dead.connect(func(): dispatch(&"dead"))
	add_transition(alive, dead, &"dead")
	
	alive.add_transition(onground, falling, &"fall", func (): character.velocity.y < 10)
	alive.add_transition(falling, onground, &"landed")
	onground.call_on_update(func (delta): if not character.is_on_floor(): dispatch(&"fall"))
	
	onground.add_transition(not_hit, hit_reaction, &"hit")
	character.hit.connect(func(): dispatch(&"hit"))
	onground.add_transition(hit_reaction, not_hit, hit_reaction.EVENT_FINISHED)
	
	character.target_spotted.connect(func(): dispatch(&"target_spotted"))
	not_hit.add_transition(patrol, attack, &"target_spotted")
	
	initialize(character)
	set_active(true)
	
