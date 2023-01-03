extends Node2D

const car_template : Resource = preload("res://car.tscn")
const radio_template : Resource = preload("res://radio.tscn")
const player_controller : Resource = preload("res://controllers/player.gd")

const car_types_dir : String = "res://cars/"
var car_types : Array = []

var player_car : Car

var sfx_muffle : AudioEffect = AudioServer.get_bus_effect(1, 0)

onready var cam : Camera2D = $Cam
onready var tween : Tween = $Tween
onready var cam_start_pos : Vector2 = cam.position




func _init() -> void:
	_load_car_types()
	randomize()


func _ready() -> void:
	_start_game(true)
	

func _process(delta : float) -> void:
	pass
	

func _start_game(play_intro : bool = false) -> void:
	_reset()
	_create_cars()
	
	if play_intro:
		tween.interpolate_property(cam, "position", cam_start_pos, player_car.position, 7, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
		
	cam.follow_player = true
	player_car.get_node("Controller").in_control = true

	
func _end_game(won : bool) -> void:
	if won:
		print("you win!")
	else:
		AudioServer.set_bus_effect_enabled(1, 0, false)
		print("game over")
	# TODO implement
	
	
func _reset() -> void:
	AudioServer.set_bus_effect_enabled(1, 0, true)
	
	for child in $Cars.get_children():
		child.queue_free()
	player_car = null


func _create_cars() -> void:
	var latest_car : Car
	for spawner in $Spawners.get_children():
		if spawner.name.begins_with("StartSpawner"):
			var offset : float = 0
			for i in range(75):
				latest_car = _create_car(spawner)
				latest_car.move_local_x(-offset)
				offset += rand_range(25, 30)
		
		# create the crashed cars blocking the road
		elif spawner.name.begins_with("CrashedCar"):
			_create_car(spawner).call_deferred("ragdoll")
		
		elif spawner.name.begins_with("OppositeLane"):
			pass
				
	_convert_to_player_car(latest_car)


func _create_car(spawn_point : Node2D) -> Car:
	var car_info : CarInfo = car_types[randi() % car_types.size()]
	var new_car : Car = car_template.instance()
	
	new_car.init_car(car_info)
	new_car.global_transform = spawn_point.global_transform
	$Cars.add_child(new_car)
	
	return new_car
	

func _convert_to_player_car(car : Car) -> void:
	player_car = car
	player_car.name = "Player Car"
	
#	for audio in player_car.get_node("Audio").get_children():
#		audio.bus = "Player SFX"
	player_car.get_node("Audio").add_child(radio_template.instance())
	
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
