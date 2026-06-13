extends Control

var font: Font
var time_elapsed: float = 0.0
var particles: Array[Dictionary] = []
@onready var play_btn: Button = $MenuVBox/ButtonBox/PlayButton
@onready var quit_btn: Button = $MenuVBox/ButtonBox/QuitButton
@onready var title_label: Label = $MenuVBox/TitleLabel

func _ready() -> void:
	font = load("res://scenes/gui/Minecraft.ttf")
	play_btn.pressed.connect(_on_play)
	quit_btn.pressed.connect(_on_quit)
	_create_particles()
	_animate_entrance()

func _process(delta: float) -> void:
	time_elapsed += delta
	# Slow rainbow shimmer on title
	var hue = fmod(time_elapsed * 0.08, 1.0)
	title_label.add_theme_color_override("font_color", Color.from_hsv(hue, 0.5, 1.0))
	# Animate floating particles
	_update_particles(delta)

# ── Floating particles ──

func _create_particles() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	for i in 40:
		var rect = ColorRect.new()
		var s = randf_range(1.5, 4.0)
		rect.size = Vector2(s, s)
		rect.color = Color(
			randf_range(0.1, 0.3),
			randf_range(0.4, 0.8),
			randf_range(0.7, 1.0),
			randf_range(0.08, 0.3)
		)
		rect.position = Vector2(
			randf_range(0, vp_size.x),
			randf_range(0, vp_size.y)
		)
		rect.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(rect)
		move_child(rect, 1)  # Behind UI, in front of background
		particles.append({
			"node": rect,
			"speed": randf_range(8, 25),
			"sway": randf_range(0.5, 2.0),
			"phase": randf_range(0, TAU)
		})

func _update_particles(delta: float) -> void:
	var vp_size = get_viewport().get_visible_rect().size
	for p in particles:
		var node: ColorRect = p["node"]
		node.position.y -= p["speed"] * delta
		node.position.x += sin(time_elapsed * p["sway"] + p["phase"]) * 15.0 * delta
		if node.position.y < -10:
			node.position.y = vp_size.y + 10
			node.position.x = randf_range(0, vp_size.x)

# ── Entrance animation ──

func _animate_entrance() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

# ── Button callbacks ──

func _on_play() -> void:
	GameManager.reset_score()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/dunia.tscn")
	)

func _on_quit() -> void:
	get_tree().quit()
