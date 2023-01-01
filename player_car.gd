extends Car

func _process(delta : float) -> void:
	._process(delta)
	_check_gear()
	
	
func _check_gear() -> void:
	if throttle_percent > 0.1:
		return
		
	if Input.is_action_just_pressed("gear_up"):
		cur_gear += 1
		cur_gear %= gear_properties.size()
	

func is_throttle_pressed() -> bool:
	return !crashed and Input.is_action_pressed("gas")
	

func is_brake_pressed() -> bool:
	return crashed or Input.is_action_pressed("brake")


func get_steering_direction() -> int:
	var rotation_direction : int = 0
	
	if Input.is_action_pressed("left"):
		rotation_direction += -1
		
	if Input.is_action_pressed("right"):
		rotation_direction += 1
		
	return rotation_direction
	
