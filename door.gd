extends Node3D

signal state_changed(me)

@export var locked = false
@export var opened = false

var collision_shape : CollisionShape3D = null

enum ACTION {OPEN, CLOSE, LOCK, UNLOCK}

func iterate(node):
	if node != null and  node is StaticBody3D:
		for child in node.get_children():
			if child is CollisionShape3D:
				collision_shape = child
				print(collision_shape)
				return
	for child in node.get_children():
		iterate(child)
		
func _ready():
	iterate(self)

func get_possible_actions():
	if opened:
		return [ACTION.CLOSE]
	if locked:
		return [ACTION.UNLOCK]
	return [ACTION.LOCK, ACTION.OPEN]
	
func get_player_action(action: ACTION):
	match action:
		ACTION.OPEN: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.OPEN
		ACTION.CLOSE: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		ACTION.LOCK: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		ACTION.UNLOCK: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		
func get_action_description(action: ACTION):
	match action:
		ACTION.OPEN: return "Open the door"
		ACTION.CLOSE: return "Close the door"
		ACTION.LOCK: return "Lock the door"
		ACTION.UNLOCK: return "Unlock the door"

func open():
	if opened or locked:
		return
	$"AnimationPlayer".play("open")
	collision_shape.disabled = true
	delayed_state_change(false)
	opened = true

func close():
	if not opened:
		return
	$"AnimationPlayer".play_backwards("open")
	collision_shape.disabled = true
	delayed_state_change(false)
	opened = false

func lock():
	if opened or locked: return
	locked = true
	
func unlock():
	if opened or not locked: return
	locked = false

func act(action: ACTION):
	match action:
		ACTION.OPEN: open()
		ACTION.CLOSE: close()
		ACTION.LOCK: lock()
		ACTION.UNLOCK: unlock()
	state_changed.emit(self)
		
func _on_area_3d_body_entered(body):
	pass
	
func delayed_state_change(value: bool):
	await get_tree().create_timer(1.0).timeout
	collision_shape.disabled = value
	
