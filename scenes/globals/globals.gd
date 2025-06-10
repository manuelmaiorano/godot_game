extends Node

@export var bullet_damage = 0.01
@export var bullet_velocity = 500

@export var debug_mode = false

var slowed_down = false


func _ready() -> void:
	SignalBus.PauseGameDebug.connect(func () : get_tree().paused = true)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("unpause") and get_tree().paused == true:
		get_tree().paused = false
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		get_tree().paused = true
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("slow"):
		if slowed_down:
			Engine.set_time_scale(1)
			slowed_down = false
		else:
			Engine.set_time_scale(0.1)
			slowed_down = true
