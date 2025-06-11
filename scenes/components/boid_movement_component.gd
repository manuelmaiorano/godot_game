extends Node


@export var agent: BaseAgent
@export var bt: BTPlayer
@export var detect_area: Area3D

@export var min_distance: float = 7
@export var avoid_factor: float = 0.4

var nearby_agents = []
var current_direction = Vector3.ZERO

func _ready() -> void:
	schedule_check_nearby_agents(1)

func schedule_check_nearby_agents(timeout):
	while true:
		await agent.get_tree().create_timer(timeout).timeout
		var agent_group = agent.get_groups()[0]
		nearby_agents = detect_area.get_overlapping_bodies().filter(func (x): return x.is_in_group(agent_group))

func avoid_others():
	var move_vec = Vector2.ZERO
	for other in nearby_agents:
		if other == agent:
			continue
			
		if other.global_position.distance_to(agent.global_position) < min_distance:
			var diff = agent.global_position - other.global_position
			move_vec.x += diff.x
			move_vec.y += diff.z
	return Vector3(move_vec.x, 0, move_vec.y)

var period_update = 0.5
var current_time = 0

func update_follow_direction(delta, point):
	current_time += delta
	if current_time > period_update:
		current_direction = (point - agent.global_position).normalized()
		current_time = 0
	

func move_towards(delta, point):
	#update_follow_direction(delta, point)
	current_direction = (point - agent.global_position).normalized()
	
	var speed = agent.entity_stats.run_speed
	var seek_velocity =  current_direction * speed
	seek_velocity.y = 0
	var avoid_velocity = avoid_others()
	
	agent.velocity = avoid_factor * avoid_velocity + (1-avoid_factor) * seek_velocity
	
	agent.apply_gravity(delta)
	agent.move_and_slide()
	agent.rotate_towards_point(delta, point)
	agent.apply_orientation_to_model()
		
