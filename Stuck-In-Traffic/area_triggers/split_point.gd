extends Area2D

func _ready() -> void:
	connect("body_exited", self, "_on_body_exited")
	pass
	
	
func _on_body_exited(car : PhysicsBody2D) -> void:
	if car is Car and car.get_node("Controller") is AI and randi() % 2 == 0:
		var ai : AI = car.get_node("Controller")
		if !ai.merging:
			ai.merge(false)
		
		
