extends Control

var font: Font
var title_label: Label
var time_elapsed: float = 0.0
var particles: Array[Dictionary] = []

func _ready() -> void:
	font = load("res://scenes/gui/Minecraft.ttf")
	_build_ui()
	_create_particles()
	_animate_entrance()

func _process(delta: float) -> void:
	time_elapsed += delta
	# Slow rainbow shimmer on title
	var hue = fmod(time_elapsed * 0.08, 1.0)
	title_label.add_theme_color_override("font_color", Color.from_hsv(hue, 0.5, 1.0))
	# Animate floating particles
	_update_particles(delta)

func _build_ui() -> void:
	# ── Dark background ──
	var bg = ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.08)
	add_child(bg)

	# ── Centered content ──
	var center = VBoxContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 8)
	center.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(center)

	# Push content slightly above center
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_spacer.size_flags_stretch_ratio = 0.7
	center.add_child(top_spacer)

	# ── Title ──
	title_label = Label.new()
	title_label.text = "OXIGEN"
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 80)
	title_label.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.15, 0.3))
	title_label.add_theme_constant_override("outline_size", 10)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title_label)

	# ── Subtitle ──
	var subtitle = Label.new()
	subtitle.text = "TOP DOWN"
	subtitle.add_theme_font_override("font", font)
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.45, 0.55, 0.65))
	subtitle.add_theme_color_override("font_outline_color", Color(0.0, 0.05, 0.1))
	subtitle.add_theme_constant_override("outline_size", 4)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(subtitle)

	# ── Gap before buttons ──
	var mid_spacer = Control.new()
	mid_spacer.custom_minimum_size.y = 60
	center.add_child(mid_spacer)

	# ── Buttons ──
	var btn_box = VBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 16)
	btn_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(btn_box)

	var play_btn = _create_button("PLAY", Color(0.15, 0.85, 0.4))
	play_btn.pressed.connect(_on_play)
	btn_box.add_child(play_btn)

	var quit_btn = _create_button("QUIT", Color(0.85, 0.2, 0.25))
	quit_btn.pressed.connect(_on_quit)
	btn_box.add_child(quit_btn)

	# Bottom spacer
	var bot_spacer = Control.new()
	bot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(bot_spacer)

	# ── Version label ──
	var version = Label.new()
	version.text = "v1.0"
	version.add_theme_font_override("font", font)
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.25, 0.25, 0.35))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(version)

func _create_button(text: String, accent: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 26)
	btn.custom_minimum_size = Vector2(220, 0)

	# Normal style
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent, 0.12)
	normal.border_color = Color(accent, 0.5)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	btn.add_theme_stylebox_override("normal", normal)

	# Hover style
	var hover = normal.duplicate()
	hover.bg_color = Color(accent, 0.25)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)

	# Pressed style
	var pressed = normal.duplicate()
	pressed.bg_color = Color(accent, 0.4)
	pressed.border_color = Color(accent, 0.9)
	btn.add_theme_stylebox_override("pressed", pressed)

	# Focus style
	var focus = normal.duplicate()
	focus.border_color = accent
	btn.add_theme_stylebox_override("focus", focus)

	# Font colors
	btn.add_theme_color_override("font_color", Color(accent, 0.9))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_focus_color", accent)

	return btn

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
