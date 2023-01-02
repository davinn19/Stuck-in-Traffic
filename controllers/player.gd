extends Controller


func _process(delta : float) -> void:
	if !is_inside_tree():
		queue_free()
		car.queue_free()
		set_process(false)
		return
		
	_check_gear()
	check_steering_input()
	update_throttle(Input.is_action_pressed("gas"))
	update_brake(Input.is_action_pressed("brake"))
	

func _check_gear() -> void:
	if Input.is_action_just_pressed("shift_gear"):
		car.cur_gear += 1
		car.cur_gear %= car.gear_properties.size()
	
		
func check_steering_input() -> void:
	var rotation_direction : int = 0
	
	if Input.is_action_pressed("left"):
		rotation_direction += -1
		
	if Input.is_action_pressed("right"):
		rotation_direction += 1
		
	car.steering_direction = rotation_direction
