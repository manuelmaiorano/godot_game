extends Node

# Task parameters.
@export var agent: BaseAgent
@export var agent_bt_player: BTPlayer
@export var velocity_to_fall: float = -20
@onready var bt_player: BTPlayer = %BTPlayer

var falling = false

func _ready() -> void:
	bt_player.agent_node = agent.get_path()
	bt_player.active = false
	bt_player.behavior_tree_finished.connect(func (x): agent_bt_player.active = true; bt_player.active = false; falling = false)

func _physics_process(delta: float) -> void:
	if falling:
		return
	if not agent.is_on_floor() and agent.velocity.y < velocity_to_fall:
		agent_bt_player.active = false
		bt_player.active = true
		falling = true
		
