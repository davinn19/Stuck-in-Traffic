extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_car_entered")
	
	
func _on_car_entered(car : PhysicsBody2D) -> void:
	if car is Car and car.get_node("Controller") is Player:
		car.call_deferred("ragdoll")
		$SirenSound.play()
	
