class_name Car
extends KinematicBody2D

signal gear_switched
signal crashed

const car_mass : int = 100

const ragdoll_template : Resource = preload("res://ragdoll_car.tscn")
# contains rpm, steering sensitivity
const gear_properties : Array = [[500, 0.8], [100, 1.2]]

var cur_gear : int = 0

var velocity : float = 0
var rpm : float = 0
var terrain_modifier : float = 0
	
var throttle_percent : float = 0
var brake_percent : float = 0
var steering_direction : int = 0

var health : float = 5
	
	
func _init() -> void:
	connect("gear_switched", self, "_switch_gear")
	

func init_car(car_info : CarInfo) -> void:
	$Sprites.generate_layers(car_info.texture, car_info.num_layers)
	$Hitbox.shape.extents = car_info.shadow_size / 2.0
	

func _process(delta : float) -> void:
	if health <= 0:
		ragdoll()
		return
		

	rpm = lerp(0, _get_rpm(), -brake_percent + 1)

	velocity = max(velocity + _get_acceleration() * delta, 0)
	$Audio/EngineSound.pitch_scale = 1 + velocity / 100
	
	var collision : KinematicCollision2D = move_and_collide(Vector2.RIGHT.rotated(rotation) * 2 * velocity * delta, false)
	if collision:
		_on_car_collide(collision.collider)
	
	# TODO scale with velocity like normal car (no spinning in place/low speeds)
	rotation += steering_direction * delta * sign(velocity) * _get_steering_sensitivity()


func _get_acceleration() -> float:
	var drag_force : float = 0.3 * pow(velocity, 2)
	var force : float = rpm - drag_force - (brake_percent * velocity * 200 + 100) - terrain_modifier
	var acceleration = (health / 5) * force / car_mass
	
	terrain_modifier = 0
	return acceleration
	

# creates new ragdoll car, moves all children inside current car
# to ragdoll car, and preserves linear velocity
func ragdoll() -> RagdollCar:
	emit_signal("crashed")
	$Controller.queue_free()
	
	var ragdoll_car : RagdollCar = ragdoll_template.instance() as RagdollCar
	ragdoll_car.global_transform = global_transform
	
	for child in get_children():
		if child is Node2D:
			var old_transform : Transform2D = child.transform
			remove_child(child)
			ragdoll_car.add_child(child)
			child.transform = old_transform
		else:
			remove_child(child)
			ragdoll_car.add_child(child)
	
	ragdoll_car.linear_velocity = Vector2.RIGHT.rotated(rotation) * velocity
	
	get_tree().root.get_node("Main/Cars").add_child(ragdoll_car)
	
	ragdoll_car.get_node("KinematicHitDetection").add_child(ragdoll_car.get_node("Hitbox").duplicate())
	
	get_parent().remove_child(self)
	return ragdoll_car
	

# when hitting something, turn yourself into ragdoll
# if the other car is not a ragdoll already, turn it into a ragdoll
func _on_car_collide(other_car : PhysicsBody2D) -> void:
	$Audio/CrashSound.play()
	if other_car.has_method("ragdoll"):
		other_car.remove_non_crash_sounds()
		other_car.ragdoll()
	remove_non_crash_sounds()
	ragdoll()
	
	
func remove_non_crash_sounds() -> void:
	for audio in $Audio.get_children():
		if audio.name != "CrashSound":
			audio.queue_free()
		

# ragdolls car before sinking
func sink() -> void:
	ragdoll().sink()
		
		
func _get_rpm() -> float:
	var base_rpm : float = gear_properties[cur_gear][0]
	return base_rpm * (throttle_percent + 1)
	

func _get_steering_sensitivity() -> float:
	return gear_properties[cur_gear][1]
