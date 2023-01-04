extends Area2D

onready var main : Node = get_node("../../")

func _ready() -> void:
	set_physics_process(false)
	yield(get_tree().create_timer(3), "timeout")
	set_physics_process(true)
	

func _physics_process(_delta : float) -> void:
	if get_overlapping_bodies().empty():
		main.create_car(self)
