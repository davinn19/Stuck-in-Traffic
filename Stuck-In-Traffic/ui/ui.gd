class_name UI
extends CanvasLayer

signal covered
signal uncovered
signal message_cleared
signal message_displayed

const title_text : String = "Stuck in Traffic"
const start_text : String = "Hold Brake to Start"
const loss_text : String = "Game Over"
const restart_text : String = "Hold Brake to Restart"
const victory_text : String = "You Win!"

onready var text_box : Label = $Text
onready var text_anim : AnimationPlayer = $Text/AnimationPlayer
onready var cover_anim : AnimationPlayer = $TransitionCover/AnimationPlayer


func _ready() -> void:
	text_box.visible = false
	

func clear_message() -> void:
	text_anim.play("Fade Out")
	yield(text_anim, "animation_finished")
	text_box.text = ""
	emit_signal("message_cleared")


func display_message(text : String) -> void:
	if text_box.visible:
		clear_message()
		yield(self, "message_cleared")
	text_box.text = text
	text_anim.play("Fade In")
	yield(text_anim, "animation_finished")
	emit_signal("message_displayed")
	

func cover() -> void:
	cover_anim.play("Cover")
	clear_message()
	yield(cover_anim, "animation_finished")
	emit_signal("covered")
	
	
func uncover() -> void:
	cover_anim.play("Uncover")
	yield(cover_anim, "animation_finished")
	emit_signal("uncovered")
