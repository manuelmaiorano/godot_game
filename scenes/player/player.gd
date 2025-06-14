extends BaseAgent


@export var mouse_sensitivity:float = 500
@export var clamp_pitch_rotation:float = 80
@export var move_speed: float = 10
@export var timescale_mult: float = 0.1

@onready var camera_3d: Camera3D = %Camera3D
@onready var pitch:Node3D = %Pitch
@onready var yaw:Node3D =  %Yaw
@onready var camera_animation: AnimationPlayer = %CameraAnimation

@onready var state_chart: StateChart = %StateChart
@onready var shoot_from: Marker3D = %ShootFrom


var active_item: Item = null

@export var item_amounts: Dictionary[Item, int]
@export var money: int = 1000

var current_ballista = null


func _enter_tree() -> void:
	SignalBus.InventoryItemSelected.connect(on_inventory_item_selected)
	SignalBus.TrySell.connect(on_try_sell)
	SignalBus.ItemBought.connect(on_item_bought)
	SignalBus.EnemyKilled.connect(func (x): money += x; SignalBus.MoneyChanged.emit(money))
	SignalBus.BallistaModeEnter.connect(func(x): current_ballista = x; state_chart.send_event("ballista"))
	SignalBus.BallistaModeExit.connect(func(): state_chart.send_event("ballista_exit"))
	took_damage.connect(func(x): SignalBus.PlayerHealthChanged.emit(x))
	dead.connect(func(): state_chart.send_event("die"))
	
func _ready():
	super._ready()
	SignalBus.ItemsChanged.emit(item_amounts)
	SignalBus.MoneyChanged.emit(money)
	SignalBus.PlayerHealthChanged.emit(1)

func die():
	return
	

func reduce_health(damage):
	if Globals.debug_mode:
		return
	else :
		super.reduce_health(damage)
	
	
func on_item_bought(item):
	
	money -= item.price
	SignalBus.MoneyChanged.emit(money)
	if item_amounts.has(item):
		item_amounts[item] += 1
	else:
		item_amounts[item] = 1
	SignalBus.ItemsChanged.emit(item_amounts)
	
func on_try_sell(item: Item):
	
	if item_amounts.has(item):
		if item_amounts[item] == 0:
			return
		item_amounts[item] -= 1
	else:
		return
		
	money += item.price
	SignalBus.MoneyChanged.emit(money)
	
	SignalBus.ItemSold.emit(item)
	SignalBus.ItemsChanged.emit(item_amounts)


func on_inventory_item_selected(item: Item):
	active_item = item

func attach_to(target):
	return
	disable_collision()
	state_chart.set_physics_process(false)
	reparent(target)

### free cam

func _on_free_camera_state_unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
		
	var mouse_movement:Vector2 = event.relative / mouse_sensitivity * PI
	
	pitch.rotation_degrees.x = clamp(pitch.rotation_degrees.x - rad_to_deg(mouse_movement.y), -clamp_pitch_rotation, clamp_pitch_rotation )
	yaw.rotate_y(-mouse_movement.x )

### ballista cam

func _on_ballista_camera_state_unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
		
	var mouse_movement:Vector2 = event.relative / mouse_sensitivity * PI
	
	current_ballista.pitch.rotation_degrees.x = clamp(current_ballista.pitch.rotation_degrees.x - rad_to_deg(mouse_movement.y), -clamp_pitch_rotation, clamp_pitch_rotation )
	current_ballista.yaw.rotate_y(-mouse_movement.x )

### IDLE

func _on_idle_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "idle"
	
func _on_idle_state_physics_processing(delta: float) -> void:
	var movement_direction:Vector2 = Input.get_vector("backward", "forward", "left", "right")
	if not movement_direction.is_zero_approx():
		state_chart.send_event("running")
	
	
	velocity.x = 0
	velocity.z = 0
	velocity += gravity * delta
	
	move_and_slide()


func _on_idle_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("aim"):
		camera_animation.play("zoom_in")
		state_chart.send_event("aim")

### RUN
func _on_run_state_physics_processing(delta: float) -> void:
	var movement_direction:Vector2 = Input.get_vector("backward", "forward", "left", "right")
	if movement_direction.is_zero_approx():
		state_chart.send_event("no_input")
	
	if not is_on_floor():
		state_chart.send_event("falling")
		return
	
	if Input.is_action_just_pressed("jump"):
		state_chart.send_event("jump")
		return
		
	var camera_basis : Basis = camera_3d.global_basis
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	var target = - camera_x * movement_direction.y + camera_z * movement_direction.x
	if target.is_zero_approx():
		return
		
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * rotation_interpolate_spped))
	
	
	#apply_root_motion_to_velocity(delta, false)
	apply_lateral_velocity(entity_stats.run_speed)
	apply_gravity(delta)
	
	move_and_slide()
	
	apply_orientation_to_model()


func _on_run_state_entered() -> void:
	animation_tree["parameters/TimeScale/scale"] = entity_stats.run_speed * timescale_mult
	animation_tree["parameters/Transition/transition_request"] = "run"
	
### FALL

func _on_falling_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "fall"
	
func _on_falling_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("landed")
		return
		
	velocity += gravity * delta
	
	move_and_slide()

### JUMP


func _on_jumping_state_entered() -> void:
	animation_tree["parameters/Transition/transition_request"] = "fall"
	velocity.y = entity_stats.jump_speed


func _on_jumping_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		state_chart.send_event("landed")
	
	apply_gravity(delta)
	move_and_slide()
	

### AIM


func _on_aiming_state_physics_processing(delta: float) -> void:
	var q_from = orientation.basis.get_rotation_quaternion()
	var q_to = yaw.basis.get_rotation_quaternion()
	# Interpolate current rotation with desired one.
	orientation.basis = Basis(q_from.slerp(q_to, delta * rotation_interpolate_spped))
	
	velocity.x = 0
	velocity.z = 0
	
	velocity += gravity * delta
	
	move_and_slide()
	
	
	$chessinggame.global_transform.basis = orientation.basis
	$chessinggame.rotate_y(deg_to_rad(180))

func get_target_collider():
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	
	var ch_pos = crosshair.position + crosshair.size * 0.5
	var ray_from = camera_3d.project_ray_origin(ch_pos)
	var ray_dir = camera_3d.project_ray_normal(ch_pos)
		
	var col = get_parent().get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		ray_from, ray_from + ray_dir * 1000, 0b10))
	
	if col.is_empty():
		return null
	return col.collider
	
func get_target_position():
	
	var target_position
	var crosshair = get_tree().get_first_node_in_group("crosshair")
	
	var ch_pos = crosshair.position + crosshair.size * 0.5
	var ray_from = camera_3d.project_ray_origin(ch_pos)
	var ray_dir = camera_3d.project_ray_normal(ch_pos)
		
	var col = get_parent().get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		ray_from, ray_from + ray_dir * 1000, collision_mask))
		
	if col.is_empty():
		target_position = ray_from + ray_dir * 1000
	else:
		target_position = col.position
	
	return target_position

func _on_aiming_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		
		if active_item == null:
			return
			
		if item_amounts[active_item] <= 0:
			return
			
		item_amounts[active_item] -= 1
		SignalBus.ItemsChanged.emit(item_amounts)
			
		if active_item.name == &"pew":
			var instance = preload("res://scenes/weapons/bullet.tscn").instantiate()
			var start_position = shoot_from.global_position
			var target_position = get_target_position()
			
			get_parent().add_child(instance)
			instance.global_position = start_position
			instance.shooter = self
			instance.velocity = (target_position - start_position).normalized() * Globals.bullet_velocity
		
		if active_item.name == &"trap":
			var instance = preload("res://scenes/weapons/trap.tscn").instantiate()
			
			get_parent().add_child(instance)
			instance.global_position = get_target_position()
		
		if active_item.name == &"branch":
			var collider: Node = get_target_collider()

			if collider:
				if collider.has_method("set_antagonists_check"):
					collider.set_antagonists_check(func (x): return not x.is_in_group("player"))
				return
			
	if Input.is_action_just_pressed("aim"):
		camera_animation.play_backwards("zoom_in")
		state_chart.send_event("stop_aim")


func _on_aiming_state_entered() -> void:
	var cross_hair = get_tree().get_first_node_in_group("crosshair")
	if cross_hair:
		cross_hair.show()


func _on_aiming_state_exited() -> void:
	var cross_hair = get_tree().get_first_node_in_group("crosshair")
	if cross_hair:
		cross_hair.hide()

### DEAD

func _on_dead_state_entered() -> void:
	SignalBus.PlayerDead.emit()
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

	
### Operating Ballista
func _on_operating_ballista_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		current_ballista.fire()
		return

func _on_operating_ballista_state_entered() -> void:
	current_ballista.make_camera_current()
	current_ballista.shooter = self
	get_tree().get_first_node_in_group("ballista_crosshair").show()


func _on_operating_ballista_state_exited() -> void:
	camera_3d.make_current()
	current_ballista.shooter = null
	get_tree().get_first_node_in_group("ballista_crosshair").hide()
