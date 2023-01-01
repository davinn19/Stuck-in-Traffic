extends Node2D

const car_template : Resource = preload("res://cars/blue_car.tscn")

onready var player_car : Car = $Cars/Car


func _ready() -> void:
	$SolidGround.connect("body_exited", self, "_on_car_fell")
	
	for spawner in get_children():
		if spawner.name.count("StartSpawner") > 0:
			for i in range(50):
				_create_car(spawner).move_local_x(i * -30)


func _on_car_fell(car : Car) -> void:
	car.fall()

func _create_car(spawner : Node2D) -> Car:
	var new_car : Car = car_template.instance()
	new_car.global_transform = spawner.global_transform
	$Cars.add_child(new_car)
	return new_car
