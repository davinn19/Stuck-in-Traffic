class_name AI
extends Controller

signal target_lane_reached

const lane_position_difference : int = 25

onready var target_velocity : float = lerp(25, 35, randf())
onready var aggression : float = randf()

onready var brake_detection : Area2D = $BrakeDetection
var base_detection_size : float

var base_rotation : float
var target_rotation : float

var target_lane_position : float

var merging : bool = false


func _ready() -> void:
	yield(self, "ready")
	_init_brake_detection()
	_update_brake_detection()
	
	target_lane_position = _get_lane_position()
	
	if abs(car.rotation_degrees - (-45)) < 90:
		base_rotation = -45
	else:
		base_rotation = -45 + 180
		
	target_rotation = base_rotation


func _process(delta : float) -> void:
	update_brake(_wants_to_brake())
	update_throttle(_wants_to_throttle())
	_update_brake_detection()
	_align_lane_position()
	_align_rotation()
	
	
func _init_brake_detection() -> void:
	var hitbox_size : Vector2 = get_node("../Hitbox").shape.extents
	base_detection_size = hitbox_size.y * 2
	brake_detection.position.x = hitbox_size.x + 1
	brake_detection.scale = Vector2.ONE * base_detection_size
	
	
func _update_brake_detection() -> void:
	brake_detection.scale.x = base_detection_size + car.velocity / (lerp(1, 2, aggression))
	
	
# brakes if there is something in front,
# otherwise, brake if going faster than target velocity
func _wants_to_brake() -> bool:
	if !brake_detection.get_overlapping_bodies().empty():
		return true
	
	return car.velocity > target_velocity
	
	
func _wants_to_throttle() -> bool:
	return !_wants_to_brake() and car.velocity / target_velocity < 0.6 * aggression
	

func _align_lane_position() -> void:
	var difference : float = _get_lane_position() - target_lane_position
	var progress : float = abs(difference) / lane_position_difference
	
	if progress < 0.01:
		target_rotation = base_rotation
		emit_signal("target_lane_reached")
	else:
		target_rotation = base_rotation - sign(difference) * lerp(0, 40, progress)
		

func _align_rotation() -> void:
	var rotation_difference : float = car.rotation_degrees - target_rotation
	if rotation_difference > 0.5:
		car.steering_direction = -1
	elif rotation_difference < -0.5:
		car.steering_direction = 1
	
	
# TODO more effective detection of cars on left/right before merging
func merge(merge_left : bool) -> void:
	merging = true
	brake_detection.scale.y += 2
	
	var old_brake_pos : float = brake_detection.position.y
	
	
	if merge_left:
		target_lane_position -= lane_position_difference
	else:
		target_lane_position += lane_position_difference
	
	yield(self, "target_lane_reached")
	target_rotation = base_rotation
	merging = false
	brake_detection.scale.y -= 2
	brake_detection.position.y = old_brake_pos
		

func _get_lane_position() -> float:
	return car.position.y + car.position.x
