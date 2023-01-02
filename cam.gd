extends Camera2D


var player : WeakRef

func _process(delta : float) -> void:
	if player.get_ref():
		position = player.get_ref().position
