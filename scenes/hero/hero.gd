extends CharacterBody2D
class_name Hero

signal died

@export var health: int = 5
@export var speed: float = 200.0
@export var knockback_strength: float = 300.0
@export var knockback_decay: float = 150.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D

var _knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_velocity := Vector2.ZERO

	if direction != Vector2.ZERO:
		move_velocity = direction * speed
		animasi.play("walk")
		if direction.x >= 0:
			animasi.flip_h = false
		else:
			animasi.flip_h = true
	else:
		animasi.play("idle")

	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	if _knockback_velocity.length() <= 150:
		$AnimatedSprite2D.modulate = Color.WHITE
		_knockback_velocity = Vector2.ZERO
	else:
		$AnimatedSprite2D.modulate = Color.GRAY
	velocity = move_velocity + _knockback_velocity
	move_and_slide()

func damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> int:
	health -= amount
	if knockback_direction != Vector2.ZERO:
		_knockback_velocity = knockback_direction.normalized() * knockback_strength
	if health <= 0:
		die()
	return health

func die() -> void:
	died.emit()
	queue_free()
