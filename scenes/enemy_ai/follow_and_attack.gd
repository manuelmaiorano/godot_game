extends LimboHSM

@onready var idle: LimboState = %Idle
@onready var walk: LimboState = %Walk
@onready var attack: LimboState = %Attack
@onready var cool_down: LimboState = %CoolDown

@export var distance_to_attack: float

func _setup() -> void:
	
	agent.animation_tree.animation_finished.connect(on_animation_finished)
	
	idle.call_on_enter(_on_idle_state_entered)\
		.call_on_update(_on_idle_state_physics_processing)
	
	walk.call_on_enter(_on_walk_state_entered)\
		.call_on_update(_on_walk_state_physics_processing)
		
	attack.call_on_enter(_on_attack_state_entered)\
		.call_on_update(_on_attack_state_physics_processing)\
		.call_on_exit(_on_attack_state_exited)
	
	cool_down.call_on_enter(_on_cooldown_state_entered)\
		.call_on_update(_on_cooldown_state_physics_processing)

	add_transition(idle, walk, &"go_to_target")
	
	add_transition(walk, idle, &"stop_moving")
	add_transition(walk, attack, &"attack")

	add_transition(attack, cool_down, attack.EVENT_FINISHED)
	add_transition(attack, idle, &"deaggro")
	
	add_transition(cool_down, walk, cool_down.EVENT_FINISHED)
	
func on_animation_finished(anim_name):
	if anim_name == "lounge_attack" or anim_name == "attack":
		dispatch(attack.EVENT_FINISHED)

#IDLE
func _on_idle_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"

func _on_idle_state_physics_processing(delta: float) -> void:
	agent.velocity.x = 0
	agent.velocity.z = 0
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()


#WALK
func _on_walk_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "walk"

func _on_walk_state_physics_processing(delta: float) -> void:
	if not agent.is_on_floor():
		dispatch(&"falling")
		return
		
	if agent.target == null or agent.target.is_dead:
		dispatch(&"stop_moving")
		return
		
	if agent.global_position.distance_to(agent.target.global_position) < distance_to_attack:
		dispatch(&"attack")
		return
	
	agent.rotate_towards_target(delta, agent.target)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()



#ATTACK
func _on_attack_state_entered() -> void:
	var should_dodge = false
	if should_dodge:
		agent.animation_tree["parameters/Transition/transition_request"] = "dodge"
	else:
		agent.animation_tree["parameters/Transition/transition_request"] = "attack"


func _on_attack_state_physics_processing(delta: float) -> void:
		
	if agent.target == null  or agent.target.is_dead:
		dispatch(&"deaggro")
		return
		
	agent.rotate_towards_target(delta, agent.target)
	agent.apply_root_motion_to_velocity(delta, true)
	#agent.velocity += gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()


func _on_attack_state_exited() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"

#COOLDOWN
func _on_cooldown_state_entered() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = "idle"
	schedule_end_cooldown()
	
func schedule_end_cooldown():
	await  get_tree().create_timer(0.5).timeout
	dispatch(cool_down.EVENT_FINISHED)

func _on_cooldown_state_physics_processing(delta: float) -> void:
	agent.velocity.x = 0
	agent.velocity.z = 0
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()
