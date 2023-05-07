class_name CarSpawner
extends Area2D

onready var main : Node = get_node("../../")

func _ready() -> void:
	main.connect("game_ended", self, "set_physics_process", [false])
	main.connect("game_loaded", self, "set_physics_process", [true])

	set_physics_process(false)
	

func _physics_process(_delta : float) -> void:
	if get_overlapping_bodies().empty():
		main.create_car(self, main.ai_controller)
