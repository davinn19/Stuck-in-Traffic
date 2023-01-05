extends Area2D

func _ready() -> void:
	connect("body_entered", self, "_on_car_sunken")
	
	
func _on_car_sunken(car : PhysicsBody2D) -> void:
	if car is Car and car.has_method("sink"):
		car.call_deferred("sink")
