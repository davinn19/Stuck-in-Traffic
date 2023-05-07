class_name Controller
extends Node

var car : Car

func _ready() -> void:
	yield(self, "ready")
	car = get_parent() as Car
	
	
# use these functions to change the throttle/brake, change the steering manually

func update_throttle(pressed : bool) -> void:
	if pressed:
		car.throttle_percent = min(1, car.throttle_percent + .1)
	else:
		car.throttle_percent = max(0, car.throttle_percent - .1)


func update_brake(pressed : bool) -> void:
	if pressed:
		car.brake_percent = min(1, car.brake_percent + .1)
	else:
		car.brake_percent = max(0, car.brake_percent - .1)
