extends Node3D
@export var enabled = true

func _ready() -> void:
	if not enabled:
		set_process(false)
		
func _process(delta: float) -> void:
	var _time = Time.get_ticks_msec() / 1000.0
 
	DebugDraw2D.set_text("Time", _time)
	DebugDraw2D.set_text("Frames drawn", Engine.get_frames_drawn())
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	DebugDraw2D.set_text("delta", delta)
