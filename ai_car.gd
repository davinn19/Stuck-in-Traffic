class_name AICar
extends Car

onready var hit_detection : Area2D = $HitDetection
onready var target_velocity : float = lerp(30, 35, randf())


# brakes if there is something in front,
# otherwise, brake if going faster than target velocity
func is_brake_pressed() -> bool:
	if !hit_detection.get_overlapping_bodies().empty():
		return true
	
	return velocity > target_velocity
	

func get_steering_direction() -> int:
	return 0
