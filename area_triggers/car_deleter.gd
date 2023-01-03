extends Area2D

func _ready() -> void:
	connect("body_entered", self, "_on_car_entered")
	
	
func _on_car_entered(car : PhysicsBody2D) -> void:
	if car is Car or car is RagdollCar:
		car.queue_free()
