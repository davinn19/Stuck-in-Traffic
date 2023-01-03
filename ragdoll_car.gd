class_name RagdollCar
extends RigidBody2D

onready var tween : Tween = $Tween

# triggers if kinematic hit detection hits a kinematic car
func _on_collide(car : PhysicsBody2D) -> void:
	if car.has_method("ragdoll"):
		car.get_node("Audio/CrashSound").play()
		car.call_deferred("ragdoll")


func sink() -> void:
	$KinematicHitDetection.queue_free()
	$Hitbox.queue_free()
	$Audio/SplashSound.play()
	
	tween.interpolate_property(self, "scale", scale, Vector2.ZERO, 5, Tween.TRANS_LINEAR)
	for audio in $Audio.get_children():
		tween.interpolate_property(audio, "volume_db", 0, -80.0, 5, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
