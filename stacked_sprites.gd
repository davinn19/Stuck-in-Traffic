extends Node2D

func _process(delta : float) -> void:
	if abs(global_rotation) > 0.00001:
		var difference = global_rotation
		global_rotation = 0
		for sprite in get_children():
			sprite.global_rotation += difference
