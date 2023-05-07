extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	pass
	
	
func _on_body_entered(car : PhysicsBody2D) -> void:
	if car is Car and car.get_node("Controller") is AI:
		var ai : AI = car.get_node("Controller")
		if !ai.merging:
			ai.merge(true)
		
		
