class_name UI
extends CanvasLayer

const title_text : String = "Stuck in Traffic"
const start_text : String = "Hold Brake to Start"
const loss_text : String = "Game Over"
const restart_text : String = "Hold Brake to Restart"
const victory_text : String = "You Win!"

onready var text_box : Label = $Text
onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	text_box.visible = false
	

func clear_message() -> void:
	anim.play("Fade Out")
	yield(anim, "animation_finished")
	text_box.text = ""


func display_message(text : String) -> void:
	if text_box.visible:
		anim.play("Fade Out")
		yield(anim, "animation_finished")
	text_box.text = text
	anim.play("Fade In")
	

func cover() -> void:
	anim.play("Cover")
	
	
func uncover() -> void:
	anim.play("Uncover")
