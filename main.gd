extends Node2D

const car_template : Resource = preload("res://car.tscn")
const player_controller : Resource = preload("res://controllers/player.gd")
const car_types_dir : String = "res://cars/"
var car_types : Array = []

var player_car : Car

onready var cam : Camera2D = $Cam
onready var cam_tween : Tween = $Cam/Tween
onready var cam_start_pos : Vector2 = cam.position


func _init() -> void:
	_load_car_types()
	randomize()


func _ready() -> void:
	$SolidGround.connect("body_exited", self, "_on_car_fell")
	_start_game(true)
	

func _start_game(play_intro : bool = false) -> void:
	_reset()
	_create_cars()
	
	if play_intro:
		_play_intro()
		yield(cam_tween, "tween_completed")
		
	
	cam.follow_player = true
	player_car.get_node("Controller").in_control = true
	
	
func _reset() -> void:
	for child in $Cars.get_children():
		child.queue_free()
	player_car = null


func _create_cars() -> void:
	var latest_car : Car
	for spawner in $Spawners.get_children():
		if spawner.name.count("StartSpawner") > 0:
			var offset : float = 0
			for i in range(75):
				latest_car = _create_car(spawner)
				latest_car.move_local_x(-offset)
				offset += rand_range(25, 30)
		
		elif spawner.name.count("CrashedCar") > 0:
			_create_car(spawner).call_deferred("ragdoll")
				
	_convert_to_player_car(latest_car)
	
	
func _play_intro() -> void:
	cam_tween.interpolate_property(cam, "position", cam_start_pos, player_car.position, 7, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	cam_tween.start()
	
	
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
	

func _convert_to_player_car(car : Car) -> void:
	player_car = car
	var controller : Node = player_car.get_node("Controller")
	controller.set_script(player_controller)
	controller.car = player_car
	
	cam.player = weakref(player_car)
	player_car.connect("crashed", self, "_end_game", [false])

	
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
