class_name CarSpawner
extends Area2D

onready var main : Node = get_node("../../")

func _ready() -> void:
	main.connect("game_ended", self, "set_physics_process", [false])

	set_physics_process(false)
	yield(main, "game_started")
	set_physics_process(true)
	

func _physics_process(_delta : float) -> void:
	if get_overlapping_bodies().empty():
		main.create_car(self)
