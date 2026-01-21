extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/playback")

func set_move_state (state_name: String):
	move_state_machine.travel(state_name)
