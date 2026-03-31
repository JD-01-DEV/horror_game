extends CharacterBody3D


const SPEED = 2.0
const TARGET_RANGE = 1.0
const ATTACK_RANGE = 1.0
var player: CharacterBody3D = null
@export var player_path: NodePath
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $zombie/AnimationTree
@onready var jumpscare_camera: Camera3D = $zombie/JumpscareCamera

var target_in_range: bool
var in_jumpscare_range: bool

func _ready() -> void:
	player = get_node(player_path)
	
func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	handle_targeting()
	if in_jumpscare_range:
		handle_camera_zoom(delta)
	move_and_slide()

func handle_movemenet():
	nav_agent.set_target_position(player.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED
	
	look_at(Vector3(player.global_position.x, global_position.y , player.global_position.z), Vector3.UP)
	anim_tree.set("parameters/LocoMotion/blend_position", Vector2(0, 1))

func handle_targeting():
	#target_in_range = global_position.direction_to(player.global_position) < Vector3(TARGET_RANGE, 0, TARGET_RANGE)
	if target_in_range:
		handle_movemenet()
	else: 
		anim_tree.set("parameters/LocoMotion/blend_position", Vector2(0, 0))
func handle_roaming():
	print("raoming")


# collision 
func _on_taraget_range_body_entered(body: Node3D) -> void:
	target_in_range = true

func _on_taraget_range_body_exited(body: Node3D) -> void:
	target_in_range = false


func _on_jumpscare_range_body_entered(body: Node3D) -> void:
	print ("scar you!")
	if (body.name == "Player"):
		jumpscare_camera.make_current()
		in_jumpscare_range = true
		body.set_physics_process(false)
		anim_tree.set("parameters/Blend2/blend_amount", 1)
		
	
func handle_camera_zoom(delta: float):
	# this line of code is the help of Duck AI.
	jumpscare_camera.fov = lerp(jumpscare_camera.fov, 20.0, clamp(delta * 4.0, 0, 1))
