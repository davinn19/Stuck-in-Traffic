class_name RagdollCar
extends RigidBody2D


# triggers if kinematic hit detection hits a kinematic car
func _on_collide(car : PhysicsBody2D) -> void:
	if car.has_method("ragdoll"):
		car.call_deferred("ragdoll")


func fall() -> void:
	$KinematicHitDetection.queue_free()
	$Hitbox.queue_free()
	
	
	var tween : SceneTreeTween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 5)
	yield(tween, "finished")
	queue_free()
