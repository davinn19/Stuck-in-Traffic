class_name Car
extends KinematicBody2D

const car_mass : int = 100

const ragdoll_template : Resource = preload("res://ragdoll_car.tscn")
# contains rpm, steering sensitivity
const gear_properties : Array = [[500, 0.8], [100, 1.2]]
var cur_gear : int = 0

var velocity : float = 0
var rpm : float = 0
	
var throttle_percent : float = 0
var brake_percent : float = 0

var health : float = 5


func _process(delta : float) -> void:
	if health <= 0:
		ragdoll()
		return
		
	_check_throttle_input()
	_check_brake_input()
	rpm = lerp(0, _get_rpm(), -brake_percent + 1)

	velocity = max(velocity + _get_acceleration() * delta, 0)
	
	var collision : KinematicCollision2D = move_and_collide(Vector2.RIGHT.rotated(rotation) * 2 * velocity * delta, false)
	if collision:
		_on_car_collide(collision.collider)
	
	# TODO scale with velocity like normal car (no spinning in place/low speeds)
	rotation += get_steering_direction() * delta * sign(velocity) * _get_steering_sensitivity()


func _get_acceleration() -> float:
	var drag_force : float = 0.3 * pow(velocity, 2)
	var force : float = rpm - drag_force - (brake_percent * velocity * 200 + 100)
	var acceleration = (health / 5) * force / car_mass 
	return acceleration
	

# creates new ragdoll car, moves all children inside current car
# to ragdoll car, and preserves linear velocity
func ragdoll() -> RagdollCar:
	var ragdoll_car : RagdollCar = ragdoll_template.instance() as RagdollCar
	ragdoll_car.global_transform = global_transform
	
	for child in get_children():
		var old_transform : Transform2D = child.transform
		remove_child(child)
		ragdoll_car.add_child(child)
		child.transform = old_transform
	
	ragdoll_car.linear_velocity = Vector2.RIGHT.rotated(rotation) * velocity
	
	get_parent().add_child(ragdoll_car)
	
	ragdoll_car.get_node("KinematicHitDetection").add_child(ragdoll_car.get_node("CollisionShape2D").duplicate())
	
	queue_free()
	return ragdoll_car
	

# when hitting something, turn yourself into ragdoll
# if the other car is not a ragdoll already, turn it into a ragdoll
func _on_car_collide(other_car : PhysicsBody2D) -> void:
	if other_car.has_method("ragdoll"):
		other_car.ragdoll()
	ragdoll()
	
	
func fall() -> void:
	ragdoll().fall()
	
	
func _get_rpm() -> float:
	var base_rpm : float = gear_properties[cur_gear][0]
	return base_rpm * (throttle_percent + 1)
	

func _get_steering_sensitivity() -> float:
	return gear_properties[cur_gear][1]
	

func _check_throttle_input() -> void:
	if is_throttle_pressed():
		throttle_percent = min(1, throttle_percent + .1)
	else:
		throttle_percent = max(0, throttle_percent - .1)
	
	
func _check_brake_input() -> void:
	if is_brake_pressed():
		brake_percent = min(1, brake_percent + .1)
	else:
		brake_percent = max(0, brake_percent - .1)
	
	
func is_throttle_pressed() -> bool:
	return false
	

func is_brake_pressed() -> bool:
	return true
	

func get_steering_direction() -> int:
	return 0
