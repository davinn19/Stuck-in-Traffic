extends Controller

onready var target_velocity : float = lerp(25, 40, randf())
onready var aggression : float = randf()

onready var brake_detection : Area2D = $BrakeDetection
var base_detection_size : float

func _ready() -> void:
	yield(self, "ready")
	_init_brake_detection()
	_update_brake_detection()


func _process(delta : float) -> void:
	update_brake(_wants_to_brake())
	update_throttle(_wants_to_throttle())
	_update_brake_detection()
	
	
func _init_brake_detection() -> void:
	var hitbox_size : Vector2 = get_node("../Hitbox").shape.extents
	base_detection_size = hitbox_size.y * 2
	brake_detection.position.x = hitbox_size.x * 2
	brake_detection.scale = Vector2.ONE * base_detection_size
	
	
func _update_brake_detection() -> void:
	brake_detection.scale.x = base_detection_size + car.velocity / (lerp(1, 5, aggression))
	
	
# brakes if there is something in front,
# otherwise, brake if going faster than target velocity
func _wants_to_brake() -> bool:
	if !brake_detection.get_overlapping_bodies().empty():
		return true
	
	return car.velocity > target_velocity
	
	
func _wants_to_throttle() -> bool:
	return !_wants_to_brake() and car.velocity / target_velocity < 0.6 * aggression
	

# TODO implement merging
	
