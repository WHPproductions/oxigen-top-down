extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 15
@export var spawn_radius: float = 200.0

var _spawn_timer: float = 0.0

func _ready() -> void:
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemy/enemy.tscn") as PackedScene
	_spawn_timer = spawn_interval

func _process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = spawn_interval
	_try_spawn()

func _try_spawn() -> void:
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return
	
	var hero := get_tree().get_first_node_in_group("player") as Node2D
	if hero == null:
		return
	
	var enemy := enemy_scene.instantiate() as Node2D
	var spawn_offset := Vector2.from_angle(randf() * TAU) * spawn_radius
	enemy.global_position = hero.global_position + spawn_offset
	add_child(enemy)
