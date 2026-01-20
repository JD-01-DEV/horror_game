extends CharacterBody3D

const SPEED = 2
const RUN_SPEED = SPEED + 2.2
const SENSITIVITY = 0.005

#jump
@export var jump_height : float = 1
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))
# source: https://youtu.be/I0elaGY6hXA?feature=shared

@onready var player_camera: Camera3D = $player_camera
@onready var tp_camera: Node3D = $TPCamera/Camera3D
@onready var animation_player: AnimationPlayer = $casual_male/AnimationPlayer

@onready var player_mesh: Node3D = $casual_male

#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_jump(delta)
	move_and_slide()

#func _input(event: InputEvent) -> void:
	#handle_camera_movement(event)

func handle_camera_movement(event : InputEvent):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * SENSITIVITY
		player_camera.rotation.x -= event.relative.y * SENSITIVITY
		clamp(player_camera.rotation.x, -80 , 80)

func handle_movement ():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace target_angle
	# UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward").rotated(-tp_camera.global_rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if(Input.is_action_pressed("sprint")):
			velocity.x = direction.x * RUN_SPEED
			velocity.z = direction.z * RUN_SPEED
			animation_player.play("running")
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			animation_player.play("walking")
		
		var target_angle = -input_dir.angle() + PI/2
		player_mesh.rotation.y = target_angle
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if(is_on_floor()):
			animation_player.play("idle")

func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
		var gravity = jump_gravity if velocity.y > 0.0 else jump_gravity
		velocity.y -= gravity * delta
		animation_player.play("jump")
