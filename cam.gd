extends Camera2D


var follow_player : bool = false
var player : WeakRef

func _process(delta : float) -> void:
	if player.get_ref() and follow_player:
		position = player.get_ref().position
