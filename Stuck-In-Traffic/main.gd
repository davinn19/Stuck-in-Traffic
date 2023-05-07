class_name Main
extends Node2D

signal game_started
signal game_loaded
signal game_ended

const car_template : Resource = preload("res://car/car.tscn")
const police_car_info : Resource = preload("res://police_car.tres")

const player_controller : Resource = preload("res://controllers/player.tscn")
const ai_controller : Resource = preload("res://controllers/ai.tscn")
const prop_controller : Resource = preload("res://controllers/prop.tscn")

const car_types_dir : String = "res://car_types/"
var car_types : Array = []

var player_car : Car
var brake_held_sec : float = 0

onready var ui : UI = $UI
onready var cam : Camera2D = $Cam
onready var tween : Tween = $Tween
onready var cam_start_pos : Vector2 = cam.position

onready var start_blocker : PhysicsBody2D = $StartBlocker


func _init() -> void:
	_load_car_types()
	randomize()


func _ready() -> void:
	_play_intro()
	

func _process(delta : float):
	if Input.is_action_pressed("brake"):
		brake_held_sec += delta
		if brake_held_sec > 1:
			brake_held_sec = 0
			emit_signal("game_started")
	else:
		brake_held_sec = 0
	
	
func end_game(won : bool) -> void:
	if won:
		cam.player = null
		player_car.remove_child(player_car.get_node("Controller"))
		player_car.call_deferred("add_child", ai_controller.instance())
		
		player_car.disconnect("crashed", self, "end_game")
		player_car = null
		
		ui.display_message(ui.victory_text)
	else:
		AudioServer.set_bus_effect_enabled(1, 0, false)
		ui.display_message(ui.loss_text)
		
	yield(get_tree().create_timer(3), "timeout")
	ui.display_message(ui.restart_text)
	yield(self, "game_started")
	emit_signal("game_ended")
	_setup_new_game()
	
	
func _play_intro() -> void:
	# play crash sound
	yield(get_tree().create_timer(1), "timeout")
	$Audio/CrashSound.play()
	yield($Audio/CrashSound, "finished")
	
	_reset()
	_create_cars()
	
	# uncover after delay
	yield(get_tree().create_timer(1), "timeout")
	ui.uncover()
	yield(ui, "uncovered")
	emit_signal("game_loaded")
	
	ui.display_message(ui.title_text)
	# moves camera over traffic
	tween.interpolate_property(cam, "position", cam_start_pos, player_car.position, 5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 3)
	tween.start()
	yield(tween, "tween_all_completed")
	
	_wait_for_game_start()


func _wait_for_game_start() -> void:
	ui.display_message(ui.start_text)
	yield(self, "game_started")
	
	ui.clear_message()
	start_blocker.get_node("CollisionPolygon2D").disabled = true
	cam.follow_player = true
	player_car.get_node("Controller").in_control = true
	

func _setup_new_game() -> void:
	ui.cover()
	yield(ui, "covered")
		
	_reset()
	_create_cars()
	yield(get_tree().create_timer(1), "timeout")
	ui.uncover()
	yield(ui, "uncovered")
	emit_signal("game_loaded")

	_wait_for_game_start()
		
	
func _reset() -> void:
	AudioServer.set_bus_effect_enabled(1, 0, true)
	start_blocker.get_node("CollisionPolygon2D").disabled = false
	ui.clear_message()
	
	_clear_old_cars()
	
	player_car = null
	

func _clear_old_cars() -> void:
	var old_cars : Node = $Cars
	remove_child(old_cars)
	old_cars.queue_free()
	var new_cars : YSort = YSort.new()
	new_cars.name = "Cars"
	add_child(new_cars)


func _create_cars() -> void:
	for spawner in $Spawners.get_children():
		
		# fills road with cars
		if spawner.name.begins_with("StartSpawner"):
			var offset : float = 20
			for i in range(60):
				create_car(spawner, ai_controller).move_local_x(-offset)
				offset += rand_range(25, 30)
			
			if spawner.name == "StartSpawner":
				_create_player_car(spawner, offset)
				
		
		# create the crashed cars blocking the road
		elif spawner.name.begins_with("CrashedCar"):
			create_car(spawner, prop_controller)
		
		# fills opposite lanes with already moving cars
		elif spawner.name.begins_with("OppositeLane"):
			var offset : float = 0
			for i in range(25):
				create_car(spawner, ai_controller).move_local_x(offset)
				offset += rand_range(100, 150)
		
		elif spawner.name.begins_with("Police"):
			_create_police_car(spawner)


func create_car(spawn_point : Node2D, controller_type : Resource) -> Car:
	var car_info : CarInfo = car_types[randi() % car_types.size()]
	var new_car : Car = car_template.instance()
	
	new_car.init_car(car_info)
	new_car.global_transform = spawn_point.global_transform
	$Cars.add_child(new_car)
	
	new_car.add_child(controller_type.instance())
	
	return new_car
	

func _create_police_car(spawn_point : Node2D) -> void:
	var police_car : Car = create_car(spawn_point, prop_controller)
	police_car.init_car(police_car_info)
	

func _create_player_car(spawner : Node2D, offset : float) -> void:
	player_car = create_car(spawner, player_controller)
	player_car.move_local_x(-offset)
	player_car.name = "Player Car"
	player_car.connect("crashed", self, "end_game", [false])
	cam.player = weakref(player_car)
	
	
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
