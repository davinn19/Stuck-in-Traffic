extends Camera2D


onready var player : WeakRef = weakref(get_node("../Cars/Car"))

func _process(delta : float) -> void:
	if player.get_ref():
		position = player.get_ref().position
