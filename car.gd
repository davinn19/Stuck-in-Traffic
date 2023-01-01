class_name Car
extends KinematicBody2D

const car_mass : int = 200

# contains rpm, steering sensitivity
const gear_properties : Array = [[500, 0.8], [100, 1.2]]
var cur_gear : int = 0

var velocity : float = 0
var rpm : float = 0
	
var throttle_percent : float = 0
var brake_percent : float = 0

var crashed : bool = false


func _ready() -> void:
	pass


func _process(delta : float) -> void:
	
	_check_throttle()
	_check_brake()
	rpm = lerp(0, _get_rpm(), -brake_percent + 1)
	
	var drag_force : float = 0.3 * pow(velocity, 2)
	var force : float = rpm - drag_force - (brake_percent * 1000)
	var acceleration = force / car_mass
	
	velocity += acceleration * delta
	velocity = max(velocity + acceleration * delta, 0)
	
	var collision : KinematicCollision2D = move_and_collide(Vector2.RIGHT.rotated(rotation) * velocity * delta)
	if collision:
		_on_car_crashed(collision.collider)
	
	# TODO scale with velocity like normal car (no spinning in place/low speeds)
	rotation += get_steering_direction() * delta * sign(velocity) * _get_steering_sensitivity()


func _on_car_crashed(other_car : Car) -> void:
	other_car.crashed = true
	crashed = true
	
	
func _get_rpm() -> float:
	var base_rpm : float = gear_properties[cur_gear][0]
	return base_rpm * (throttle_percent + 1)
	

func _get_steering_sensitivity() -> float:
	return gear_properties[cur_gear][1]
	
	
func is_throttle_pressed() -> bool:
	return false
	

func is_brake_pressed() -> bool:
	return true
	

func _check_throttle() -> void:
	if is_throttle_pressed():
		throttle_percent = min(1, throttle_percent + .1)
	else:
		throttle_percent = max(0, throttle_percent - .1)
	
	
func _check_brake() -> void:
	if is_brake_pressed():
		brake_percent = min(1, brake_percent + .1)
	else:
		brake_percent = max(0, brake_percent - .1)
	
	
func get_steering_direction() -> int:
	return 0

