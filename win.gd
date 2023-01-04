extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	
	
func _on_body_entered(car : PhysicsBody2D) -> void:
	if car is Car and car.get_node("Controller") is Player:
		get_node("../../")._end_game(true)
