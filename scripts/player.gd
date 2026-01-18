extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

@onready var player_camera: Camera3D = $player_camera
@onready var tp_camera: Node3D = $TPCamera/Camera3D

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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward").rotated(-tp_camera.global_rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
