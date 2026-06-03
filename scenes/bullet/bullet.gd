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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		var knockback_dir := (body.global_position - global_position).normalized()
		if knockback_dir == Vector2.ZERO:
			knockback_dir = direction.normalized()
		body.damage(1, knockback_dir)
		queue_free()
	elif body is StaticBody2D:
		queue_free()
