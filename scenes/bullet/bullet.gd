extends Node2D

@export var speed: float = 500
@export var direction : Vector2

func _physics_process(delta: float) -> void:
	move_forward(delta)

func move_forward(delta: float) -> void:
	# Normalisasi vektor agar gerakan diagonal dan lurus bergerak dengan kecepatan yang sama.
	var move_direction: Vector2 = direction.normalized()
	position += move_direction * speed * delta # update posisi

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
