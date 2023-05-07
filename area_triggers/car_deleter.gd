extends Area2D

func _ready() -> void:
	connect("body_entered", self, "_on_car_entered")
	
	
func _on_car_entered(car : PhysicsBody2D) -> void:
	if car is Car or car is RagdollCar:
		
		# preserve radio if player gets deleted
		var audio = car.get_node("Audio")
		if audio.has_node("Radio"):
			var radio : Node2D = audio.get_node("Radio")
			var old_pos : Vector2 = radio.global_position
			audio.remove_child(radio)
			get_node("../../Cars").add_child(radio)
			radio.global_position = old_pos
			
		car.queue_free()
