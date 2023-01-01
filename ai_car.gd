extends Car

var straight_rotation : float = -45
var trying_to_merge = false

onready var hit_detection : Area2D = $HitDetection
onready var target_velocity : float = lerp(25, 35, randf())

func is_brake_pressed() -> bool:
	if !hit_detection.get_overlapping_bodies().empty():
		return true
	
	return velocity > target_velocity
	

func get_steering_direction() -> int:
	return 0
