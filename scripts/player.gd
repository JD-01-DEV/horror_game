extends CharacterBody3D

const SPEED = 2
const RUN_SPEED = SPEED + 2.2
const SENSITIVITY = 0.005


@onready var flashlight: Node3D = $casual_male/player/Skeleton3D/BoneAttachment3D/Flashlight
@onready var animation_tree: AnimationTree = $casual_male/AnimationTree

@onready var tp_camera: Camera3D = $TPCamera/Camera3D
@onready var fp_camera: Camera3D = $casual_male/FPCamera/Camera3d

#jump
@export var jump_height : float = 1
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))
# source: https://youtu.be/I0elaGY6hXA?feature=shared

@onready var player_mesh: Node3D = $casual_male

# Inputs
var forward
var backward
var left
var right
var sprinting
var jumping
var flashing
var crouching
var switch_camera
var lock_camera

var blend_pos = Vector2.ZERO
var input_dir

#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	set_inputs()
	handle_movement()
	handle_directional_movement()
	handle_crouch()
	handle_jump(delta)
	handle_flashlight()
	handle_camera_state()
	move_and_slide()

#func _input(event: InputEvent) -> void:
	#handle_camera_movement(event)

#func handle_camera_movement(event : InputEvent):
	#if event is InputEventMouseMotion:
		#rotation.y -= event.relative.x * SENSITIVITY
		#player_camera.rotation.x -= event.relative.y * SENSITIVITY
		#clamp(player_camera.rotation.x, -80 , 80)

func set_inputs():
	forward = Input.is_action_just_pressed("forward")
	backward = Input.is_action_just_pressed("backward")
	left = Input.is_action_just_pressed("left")
	right = Input.is_action_just_pressed("right")
	sprinting = Input.is_action_pressed("sprint")
	jumping = Input.is_action_just_pressed("jump")
	flashing = Input.is_action_just_pressed("flashlight")
	crouching = Input.is_action_just_pressed("crouch")
	switch_camera = Input.is_action_just_pressed("camera")
	lock_camera = Input.is_action_just_pressed("camera_lock")

func handle_movement ():
	if GameStates.FPV:
		input_dir = Input.get_vector("left", "right", "forward", "backward").rotated(-fp_camera.global_rotation.y)
	else:
		input_dir = Input.get_vector("left", "right", "forward", "backward").rotated(-tp_camera.global_rotation.y)
	var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if direction && is_on_floor():
		#var target_speed = RUN_SPEED if sprinting else SPEED
		#
		#velocity.x = move_toward(velocity.x, direction.x * target_speed, 2.0)
		#velocity.z = move_toward(velocity.z, direction.z * target_speed, 2.0)
		
		if sprinting:
			#animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, 1))
			velocity.x = move_toward(velocity.x, direction.x * RUN_SPEED, 2.0)
			velocity.z = move_toward(velocity.z, direction.z * RUN_SPEED, 2.0)
		else:
			#animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, 0.5))
			velocity.x = move_toward(velocity.x, direction.x * SPEED, 2.0)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, 2.0)
			
		var target_angle = -input_dir.angle() + PI/2
		if not GameStates.FPV:	
			player_mesh.rotation.y = target_angle
	else:
		if(is_on_floor()):
			animation_tree.set("parameters/LocoBlend/blend_amount", 0)
			animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, 0))
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_directional_movement():
	var walk := 0.5
	var walk_back := -0.5
	var left_walk := -0.5
	var right_walk := 0.5
	var run := 1
	var run_back := -1
	var left_run := -1
	var right_run := 1
	
	if not sprinting and is_on_floor():
		if forward:
			if left:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_walk, walk))
			elif right:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_walk, walk))
			else:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, walk))
				
		if backward:
			if left:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_walk, walk_back))
			elif right:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_walk, walk_back))
			else:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, walk_back))
				
		if left:
			animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_walk, 0))
			
		elif right:
			animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_walk, 0))
			
	if sprinting and is_on_floor():
		if forward:
			if left:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_run, run))
			elif right:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_run, run))
			else:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, run))
				
		if backward:
			if left:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_run, run_back))
			elif right:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_run, run_back))
			else:
				animation_tree.set("parameters/LocoMotion/blend_position", Vector2(0, run_back))
				
		if left:
			animation_tree.set("parameters/LocoMotion/blend_position", Vector2(left_run, 0))
			
		elif right:
			animation_tree.set("parameters/LocoMotion/blend_position", Vector2(right_run, 0))
	
func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if jumping and is_on_floor():
		animation_tree.set("parameters/LocoBlend/blend_amount", -1)
		velocity.y = -jump_velocity
		var gravity = jump_gravity if velocity.y > 0.0 else jump_gravity
		velocity.y -= gravity * delta
	else:
		if flashlight.visible: 
			animation_tree.set("parameters/FlashAdd/add_amount", 1)
		else: 
			animation_tree.set("parameters/FlashAdd/add_amount", 0)

func handle_flashlight():
	if flashing:
		if flashlight.visible == true:
			flashlight.visible = false
			animation_tree.set("parameters/FlashBlend/blend_amount", 0)
		else:
			flashlight.visible = true
			animation_tree.set("parameters/FlashBlend/blend_amount", 1)

func handle_crouch():
	pass
	if crouching:
		animation_tree.set("parameters/LocoBlend/blend_amount", 1)
	else:
		animation_tree.set("parameters/LocoBlend/blend_amount", 0)

func handle_camera_state():
	if switch_camera:
		if GameStates.FPV:
			GameStates.FPV = false
			tp_camera.make_current()
		else:
			GameStates.FPV = true
			fp_camera.make_current()
	
	if lock_camera:
		GameStates.camera_lock = true
		print("camera locked")
	else:
		GameStates.camera_lock = false

func _input(event: InputEvent) -> void:
	if GameStates.FPV and event is InputEventMouseMotion:
		player_mesh.rotation.y -= event.relative.x * SENSITIVITY
		fp_camera.rotation.x -= event.relative.y * SENSITIVITY
		fp_camera.rotation.x = clamp(fp_camera.rotation.x, -1, 1)
