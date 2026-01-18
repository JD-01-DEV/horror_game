extends Node3D

const SENSITIVITY = 0.005

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	rotate_from_vector(event)

func rotate_from_vector(event: InputEvent):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * SENSITIVITY
		rotation.x -= event.relative.y * SENSITIVITY
		rotation.x = clamp(rotation.x, -0.6, 0.6)
