extends Node2D

const car_template : Resource = preload("res://car.tscn")
const player_controller : Resource = preload("res://controllers/player.gd")
const car_types_dir : String = "res://cars/"
var car_types : Array = []

var player_car : Car

func _init() -> void:
	_load_car_types()
	randomize()


func _ready() -> void:
	_create_player()
	
	$SolidGround.connect("body_exited", self, "_on_car_fell")
	
	for spawner in get_children():
		if spawner.name.count("StartSpawner") > 0:
			for i in range(50):
				_create_car(spawner).move_local_x(i * -30)
				

func _physics_process(delta : float):
	for car in $Sand.get_overlapping_bodies():
		if car is Car:
			car.terrain_modifier = pow(car.velocity, 3)
			if car.health > 0:
				car.health -= delta


func _on_car_fell(car : PhysicsBody2D) -> void:
	if car and !$SolidGround.get_overlapping_bodies().has(car):
		car.call_deferred("fall")
	

func _create_car(spawn_point : Node2D) -> Car:
	var car_info : CarInfo = car_types[randi() % car_types.size()]
	var new_car : Car = car_template.instance()
	
	new_car.init_car(car_info)
	new_car.global_transform = spawn_point.global_transform
	$Cars.add_child(new_car)
	
	return new_car
	
	
func _create_player() -> void:
	player_car = _create_car($PlayerSpawn)
	var controller : Node = player_car.get_node("Controller")
	controller.set_script(player_controller)
	controller.car = player_car
	
	$Cam.player = weakref(player_car)

	
func _load_car_types() -> void:
	var dir : Directory = Directory.new()
	dir.open(car_types_dir)
	dir.list_dir_begin()
	var file_name : String = dir.get_next()

	while file_name != "": 
		if dir.current_is_dir():
			pass
		else:
			var car_info : CarInfo = load(car_types_dir + file_name)
			car_types.append(car_info)
			
		file_name = dir.get_next()
