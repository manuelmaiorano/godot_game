extends BaseAgent

var target = null
var is_biting = false
var has_caught_enemy = false
@onready var bone_attachment_3d: BoneAttachment3D = %BoneAttachment3D


func _ready() -> void:
	super._ready()
	animation_tree["parameters/Transition/transition_request"] = "run"
	target = get_tree().get_first_node_in_group("player")
	

func blend_bite(amount):
	animation_tree["parameters/blendbite/add_amount"] = amount
	
func  _physics_process(delta: float) -> void:
	if has_caught_enemy:
		blend_bite(0)
		return
	rotate_towards_target(delta, target)
	if global_position.distance_to(target.global_position) < 10:
		blend_bite(1)
		is_biting = true
	else:
		blend_bite(0)
		is_biting = false
	apply_lateral_velocity(entity_stats.run_speed)
	apply_gravity(delta)
	move_and_slide()
	apply_orientation_to_model()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		return
	
	if is_biting and check_if_antagonist(body):
		print("caught")
		body.die()
		has_caught_enemy = true
