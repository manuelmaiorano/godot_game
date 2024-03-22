extends CharacterBody3D

enum ANIMATIONS {JUMP_UP, JUMP_DOWN, STRAFE, WALK}
enum CHARACTER_ACTION {SIT, THROW, OPEN, PICK}

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

const MIN_AIRBORNE_TIME = 0.7
const JUMP_SPEED = 5

var airborne_time = 100

var orientation = Transform3D()
var root_motion = Transform3D()
var motion = Vector2()

@onready var initial_position = transform.origin
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@onready var player_input = $InputSynchronizer
@onready var animation_tree = $AnimationTree
@onready var player_model = $Human_rig
@onready var action_label = $UI/Actions/RichTextLabel


@export var player_id := 1 :
	set(value):
		player_id = value
		$InputSynchronizer.set_multiplayer_authority(value)

@export var current_animation := ANIMATIONS.WALK
#@export var current_interaction := ACTIONS.NONE

@onready var inside_car = false

#@onready var current_door = null
@onready var current_pistol = null
@onready var current_car = null

class ActionInfo:
	var object_action_id
	var player_action_id
	var desc
	
@onready var objects_to_actions: Dictionary = {}


@onready var fire_cooldown: Timer = $FireCoolDown
@onready var shoot_from = $Human_rig/GeneralSkeleton/GunBone/ShootFrom


@onready var sound_effects = $SoundEffects
@onready var sound_effect_shoot = sound_effects.get_node("Shoot")

func _ready():
	# Pre-initialize orientation transform.
	orientation = player_model.global_transform
	orientation.origin = Vector3()
	if not multiplayer.is_server():
		set_process(false)


func _physics_process(delta: float):
	if multiplayer.is_server():
		apply_input(delta)
	else:
		animate(current_animation, delta)


func animate(anim: int, delta:=0.0):
	current_animation = anim

	if anim == ANIMATIONS.JUMP_DOWN:
		animation_tree["parameters/state/transition_request"] = "fall"
	elif anim == ANIMATIONS.STRAFE:
		animation_tree["parameters/state/transition_request"] = "strafe"
		# Change aim according to camera rotation.
		#animation_tree["parameters/aim/add_amount"] = player_input.get_aim_rotation()
		# The animation's forward/backward axis is reversed.
		animation_tree["parameters/strafe/blend_position"] = Vector2(motion.x, -motion.y)

	elif anim == ANIMATIONS.WALK:
		# Aim to zero (no aiming while walking).
		#animation_tree["parameters/aim/add_amount"] = 0
		# Change state to walk.
		animation_tree["parameters/state/transition_request"] = "walk"
		animation_tree["parameters/walk/blend_position"] = motion.length()
		# Blend position for walk speed based checked motion.
		if player_input.running:
			animation_tree["parameters/run/transition_request"] = "run"
		else:
			animation_tree["parameters/run/transition_request"] = "walk"
		


func apply_input(delta: float):
	motion = motion.lerp(player_input.motion, MOTION_INTERPOLATE_SPEED * delta)

	if current_car:
		current_car.set_motion(motion)
		global_position = current_car.global_position
		return
	var camera_basis : Basis = player_input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	# pistol hide
	if not player_input.aiming and current_pistol:
		current_pistol.hide()

	# Jump/in-air logic.
	airborne_time += delta
	if is_on_floor():
		if airborne_time > 0.5:
			animate(ANIMATIONS.WALK, delta)
		airborne_time = 0

	var on_air = airborne_time > MIN_AIRBORNE_TIME

	if on_air:
		if (velocity.y <0): 
			animate(ANIMATIONS.JUMP_DOWN, delta)
	elif player_input.aiming and current_pistol != null:
		current_pistol.show()
		# Convert orientation to quaternions for interpolating rotation.
		var q_from = orientation.basis.get_rotation_quaternion()
		var q_to = player_input.get_camera_base_quaternion()
		# Interpolate current rotation with desired one.
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))

		# Change state to strafe.
		animate(ANIMATIONS.STRAFE, delta)
		
		if player_input.shooting and fire_cooldown.time_left == 0:
			var shoot_origin = shoot_from.global_transform.origin
			var shoot_dir = (player_input.shoot_target - shoot_origin).normalized()

			var bullet = preload("res://bullet.tscn").instantiate()
			get_parent().add_child(bullet, true)
			bullet.global_transform.origin = shoot_origin
			# If we don't rotate the bullets there is no useful way to control the particles ..
			bullet.look_at(shoot_origin + shoot_dir, Vector3.UP)
			bullet.add_collision_exception_with(self)
			shoot.rpc()
	elif animation_tree["parameters/state/current_state"] == "combat":
		if animation_tree["parameters/combat/playback"].get_current_node() == "basic_f_idle":
			animate(ANIMATIONS.WALK, delta)
	elif animation_tree["parameters/state/current_state"] == "talk":
		if player_input.talking:
			animation_tree["parameters/state/transition_request"] = "walk"
	elif animation_tree["parameters/state/current_state"] == "sit":
		if animation_tree["parameters/sit/playback"].get_current_node() == "basic_f_idle":
			animate(ANIMATIONS.WALK, delta)
	elif animation_tree["parameters/state/current_state"] == "throw":
		if animation_tree["parameters/throw/playback"].get_current_node() == "basic_f_idle":
			animate(ANIMATIONS.WALK, delta)
	elif animation_tree["parameters/state/current_state"] == "open":
		if animation_tree["parameters/open/playback"].get_current_node() == "basic_f_idle":
			animate(ANIMATIONS.WALK, delta)
	elif animation_tree["parameters/state/current_state"] == "pick":
		if animation_tree["parameters/pick/playback"].get_current_node() == "basic_f_idle":
			animate(ANIMATIONS.WALK, delta)
	else: # Not in air or aiming, idle.
		# Convert orientation to quaternions for interpolating rotation.
		var target = camera_x * motion.x + camera_z * motion.y
		if target.length() > 0.001:
			var q_from = orientation.basis.get_rotation_quaternion()
			var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
			# Interpolate current rotation with desired one.
			orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
		
		animate(ANIMATIONS.WALK, delta)
		if player_input.jumping and not animation_tree["parameters/jump/active"]:
			animation_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			player_input.jumping = false
		if player_input.punching:
			animation_tree["parameters/state/transition_request"] = "combat"
			animation_tree["parameters/combat/choose_action/blend_position"] = 1
		if player_input.kicking:
			animation_tree["parameters/state/transition_request"] = "combat"
			animation_tree["parameters/combat/choose_action/blend_position"] = -1
		if player_input.talking:
			animation_tree["parameters/state/transition_request"] = "talk"


	root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())
	
	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta

	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	if animation_tree["parameters/jump/active"] and not on_air:
		velocity.y = h_velocity.y
	else:
		velocity += gravity * delta
	if on_air:
		velocity += gravity * delta
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis

	# If we're below -40, respawn (teleport to the initial position).
	if transform.origin.y < -40:
		transform.origin = initial_position

	
func _process(delta):
	
	if player_input.action > 0:
		do_action_by_number(player_input.action)
	
func do_action_by_number(num):
	var i := 0
	for object in objects_to_actions:
		for action_info: ActionInfo in objects_to_actions[object]:
			i += 1
			if i == num: 
				object.act(action_info.object_action_id)
				match action_info.player_action_id:
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.PICK: 
						animation_tree["parameters/state/transition_request"] = "pick"
						current_pistol = object
						current_pistol.reparent($Human_rig/GeneralSkeleton/GunBone)
						current_pistol.transform = Transform3D(Basis(Quaternion(0.51, 0.53, 0.47, -0.48)), Vector3(-0.01, -0.014, 0.048))
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.THROW: 
						animation_tree["parameters/state/transition_request"] = "throw"
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.SIT: 
						animation_tree["parameters/state/transition_request"] = "sit"
						animation_tree["parameters/sit/conditions/stand"] =  false
						var sit_position: Transform3D = object.get_node("SitPosition").global_transform
						global_position.x = sit_position.origin.x
						global_position.z = sit_position.origin.z
						orientation.basis = sit_position.basis
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.STAND: 
						animation_tree["parameters/sit/conditions/stand"] =  true
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.OPEN: 
						animation_tree["parameters/state/transition_request"] = "open"
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.ENTER_CAR:
						current_car = object
						$CollisionShape3D.disabled = true
						hide()
					GLOBAL_DEFINITIONS.CHARACTER_ACTION.EXIT_CAR:
						current_car = null
						$CollisionShape3D.disabled = false
						show()
				return
	
func update_action_labels():
	var i := 0
	action_label.clear()
	#print(objects_to_actions)
	for object in objects_to_actions:
		var action_info_list = objects_to_actions[object]
		for action_info: ActionInfo in action_info_list:
			i += 1
			action_label.append_text("%d : %s \n" % [i, action_info.desc])
		
	
func _on_actions_update(object):
	objects_to_actions[object] = []
	for action in object.get_possible_actions():
		var action_info = ActionInfo.new()
		action_info.desc = object.get_action_description(action)
		action_info.player_action_id = object.get_player_action(action)
		action_info.object_action_id = action
		
		objects_to_actions[object].push_back(action_info)
	update_action_labels()
	

func _on_area_3d_area_entered(area):
	var object = area.get_parent()
	_on_actions_update(object)
	object.state_changed.connect(_on_actions_update)
	
func _on_area_3d_area_exited(area):
	var object = area.get_parent()
	objects_to_actions.erase(object)
	object.state_changed.disconnect(_on_actions_update)
	update_action_labels()
	
	
@rpc("call_local")
func shoot():
	#var shoot_particle = $PlayerModel/Robot_Skeleton/Skeleton3D/GunBone/ShootFrom/ShootParticle
	#shoot_particle.restart()
	#shoot_particle.emitting = true
	#var muzzle_particle = $PlayerModel/Robot_Skeleton/Skeleton3D/GunBone/ShootFrom/MuzzleFlash
	#muzzle_particle.restart()
	#muzzle_particle.emitting = true
	fire_cooldown.start()
	sound_effect_shoot.play()
	#add_camera_shake_trauma(0.35)
