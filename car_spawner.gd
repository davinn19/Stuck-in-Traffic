class_name CarSpawner
extends Node2D

const car_template : Resource = preload("res://cars/blue_car.tscn")


func _ready() -> void:
	$Timer.connect("timeout", self, "_on_timer_finished")


func create_car() -> Car:
	var new_car : Car = car_template.instance()
	new_car.global_transform = global_transform
	get_node("../Cars/").add_child(new_car)
	return new_car
	

func _on_timer_finished() -> void:
	if randi() % 2 == 0:
		create_car()
