extends Area2D

func _ready() -> void:
	connect("body_exited", self, "_on_car_sunken")
	
	
func _on_car_sunken(car : PhysicsBody2D) -> void:
	if car and car.is_inside_tree() and !get_overlapping_bodies().has(car) and car.has_method("sink"):
		car.call_deferred("sink")
