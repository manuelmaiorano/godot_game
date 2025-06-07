extends BaseAgent
@onready var pivot: Node3D = %PivotSpin
@onready var spike_animation: AnimationPlayer = %SpikeAnimation
var roll_speed = 20

func _ready() -> void:
	super._ready()
	animation_tree["parameters/TimeScale/scale"] = 3

func spikes():
	spike_animation.play("spikeout")

func roll_towards(delta, point):
	move_towards(delta, point)
	pivot.rotate_x(roll_speed * delta)
	
func reset_rotation():
	pivot.rotation.x = 0
	
