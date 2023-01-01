extends Node2D


onready var player_car : Car = $Cars/Car


func _ready() -> void:
	for spawner in get_children():
		if spawner is CarSpawner:
			for i in range(50):
				spawner.create_car().move_local_x(i * 30)
