extends Controller

onready var target_velocity : float = lerp(30, 35, randf())
var brake_detection : Area2D


func _ready() -> void:
	yield(self, "ready")
	brake_detection = car.get_node("BrakeDetection")

func _process(delta : float) -> void:
	update_brake(_wants_to_brake())
	update_throttle(_wants_to_throttle())
	
	
# brakes if there is something in front,
# otherwise, brake if going faster than target velocity
func _wants_to_brake() -> bool:
	if !brake_detection.get_overlapping_bodies().empty():
		return true
	
	return car.velocity > target_velocity
	
	
func _wants_to_throttle() -> bool:
	return !_wants_to_brake() and car.velocity / target_velocity < 0.25
	
