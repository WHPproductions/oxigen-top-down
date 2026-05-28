extends Marker2D

@export var cooldown: float = 0.1

@onready var bullet_scene: PackedScene = load("res://scenes/bullet/bullet.tscn")

var _is_trigger_held: bool = false
var _cooldown_remaining: float = 0.0

func _process(delta: float) -> void:
	# core loop
	var mouse_position: Vector2 = get_global_mouse_position()
	aim_towards(mouse_position) # Bidik pistol rotasi sesuai posisi cursor
	try_fire(mouse_position) # Tembak pistol
	update_cooldown(delta) # Update cooldown

## Bidik pistol rotasi sesuai parameter target_position
func aim_towards(target_position: Vector2) -> void:
	$Pivot.look_at(target_position)

## Mencoba menembak jika mouse kiri dipencet dan cooldown sudah beres
func try_fire(target_position: Vector2) -> void:
	if not _is_trigger_held or _cooldown_remaining > 0.0: 
		return # Jika mouse tidak dipencet atau cooldown masih ada maka diskip
	
	# Scene peluru/bullet
	var bullet: Node2D = bullet_scene.instantiate() as Node2D
	if bullet == null:
		return
	
	# Direction from the gun to the target.
	var shoot_direction: Vector2 = target_position - global_position
	bullet.direction = shoot_direction
	bullet.global_position = $Pivot/Sprite2D.global_position
	bullet.look_at(target_position)
	add_child(bullet)

	_cooldown_remaining = cooldown

## Mengupdate cooldown jika masih ada sisa cooldown
func update_cooldown(delta: float) -> void:
	if _cooldown_remaining <= 0.0:
		return
	_cooldown_remaining -= delta

func _unhandled_input(event: InputEvent) -> void:
	# Input tekan mouse kiri
	if event is InputEventMouseButton:
		_is_trigger_held = event.pressed
