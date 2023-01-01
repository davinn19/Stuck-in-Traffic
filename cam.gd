extends Camera2D


onready var player : Node2D = get_node("../Cars/Car")

func _process(delta : float) -> void:
	position = player.position
