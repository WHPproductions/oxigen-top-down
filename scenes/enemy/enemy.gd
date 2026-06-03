extends CharacterBody2D
class_name Enemy

@export var health: int = 3
@export var speed: float = 80.0
@export var knockback_strength: float = 120.0
@export var knockback_decay: float = 10.0
@export var contact_damage: int = 1
@export var contact_cooldown: float = 0.5

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D

var _knockback_velocity: Vector2 = Vector2.ZERO
var _contact_cooldown: float = 0.0
var _hero: CharacterBody2D

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if _contact_cooldown > 0.0:
		_contact_cooldown -= delta

	if not is_instance_valid(_hero):
		_hero = get_tree().get_first_node_in_group("player") as CharacterBody2D

	var chase_velocity := Vector2.ZERO
	if _hero:
		var to_hero := _hero.global_position - global_position
		if to_hero.length_squared() > 1.0:
			chase_velocity = to_hero.normalized() * speed
			animasi.play("run")
			animasi.flip_h = to_hero.x < 0.0
		else:
			animasi.play("idle")
	else:
		animasi.play("idle")

	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	velocity = chase_velocity + _knockback_velocity
	move_and_slide()

func damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	health -= amount
	if knockback_direction != Vector2.ZERO:
		_knockback_velocity = knockback_direction.normalized() * knockback_strength
	if health <= 0:
		die()

func die() -> void:
	GameManager.add_score(1)
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if _contact_cooldown > 0.0 or not body is Hero:
		return
	var knockback_dir := (body.global_position - global_position).normalized()
	body.damage(contact_damage, knockback_dir)
	_contact_cooldown = contact_cooldown
