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
	# Pulsing red glow on title
	var pulse = (sin(time_elapsed * 3.0) + 1.0) / 2.0
	var red_val = lerpf(0.7, 1.0, pulse)
	title_label.add_theme_color_override("font_color", Color(red_val, 0.1, 0.15))
	# Animate particles
	_update_particles(delta)

func _build_ui() -> void:
	# ── Dark red-tinted background ──
	var bg = ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.02, 0.03)
	add_child(bg)

	# ── Centered content ──
	var center = VBoxContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 12)
	center.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(center)

	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_spacer.size_flags_stretch_ratio = 0.7
	center.add_child(top_spacer)

	# ── Death icon ──
	var icon = Label.new()
	icon.text = "X"
	icon.add_theme_font_override("font", font)
	icon.add_theme_font_size_override("font_size", 50)
	icon.add_theme_color_override("font_color", Color(0.7, 0.1, 0.15))
	icon.add_theme_color_override("font_outline_color", Color(0.25, 0.0, 0.02))
	icon.add_theme_constant_override("outline_size", 6)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(icon)

	# ── GAME OVER title ──
	title_label = Label.new()
	title_label.text = "GAME OVER"
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.1, 0.15))
	title_label.add_theme_color_override("font_outline_color", Color(0.3, 0.0, 0.0))
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title_label)

	# ── Score display panel ──
	var score_panel = PanelContainer.new()
	score_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.04, 0.05, 0.85)
	panel_style.border_color = Color(0.45, 0.08, 0.1, 0.5)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 14
	panel_style.content_margin_bottom = 14
	panel_style.shadow_color = Color(0.3, 0.0, 0.0, 0.3)
	panel_style.shadow_size = 4
	score_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(score_panel)

	var score_row = HBoxContainer.new()
	score_row.add_theme_constant_override("separation", 12)
	score_row.alignment = BoxContainer.ALIGNMENT_CENTER
	score_panel.add_child(score_row)

	var score_title = Label.new()
	score_title.text = "SCORE:"
	score_title.add_theme_font_override("font", font)
	score_title.add_theme_font_size_override("font_size", 22)
	score_title.add_theme_color_override("font_color", Color(0.65, 0.5, 0.45))
	score_title.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.08))
	score_title.add_theme_constant_override("outline_size", 3)
	score_row.add_child(score_title)

	var score_value = Label.new()
	score_value.text = str(GameManager.score)
	score_value.add_theme_font_override("font", font)
	score_value.add_theme_font_size_override("font_size", 30)
	score_value.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	score_value.add_theme_color_override("font_outline_color", Color(0.4, 0.3, 0.0))
	score_value.add_theme_constant_override("outline_size", 4)
	score_row.add_child(score_value)

	# ── Gap ──
	var mid_spacer = Control.new()
	mid_spacer.custom_minimum_size.y = 40
	center.add_child(mid_spacer)

	# ── Buttons ──
	var btn_box = VBoxContainer.new()
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_box.add_theme_constant_override("separation", 14)
	btn_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(btn_box)

	var retry_btn = _create_button("RETRY", Color(0.2, 0.8, 0.4))
	retry_btn.pressed.connect(_on_retry)
	btn_box.add_child(retry_btn)

	var menu_btn = _create_button("MAIN MENU", Color(0.5, 0.5, 0.6))
	menu_btn.pressed.connect(_on_main_menu)
	btn_box.add_child(menu_btn)

	var bot_spacer = Control.new()
	bot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(bot_spacer)

func _create_button(text: String, accent: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 24)
	btn.custom_minimum_size = Vector2(220, 0)

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent, 0.12)
	normal.border_color = Color(accent, 0.5)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", normal)

	var hover = normal.duplicate()
	hover.bg_color = Color(accent, 0.25)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = normal.duplicate()
	pressed.bg_color = Color(accent, 0.4)
	btn.add_theme_stylebox_override("pressed", pressed)

	var focus = normal.duplicate()
	focus.border_color = accent
	btn.add_theme_stylebox_override("focus", focus)

	btn.add_theme_color_override("font_color", Color(accent, 0.9))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)

	return btn

# ── Red floating particles ──

func _create_particles() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	for i in 30:
		var rect = ColorRect.new()
		var s = randf_range(1.5, 3.5)
		rect.size = Vector2(s, s)
		rect.color = Color(
			randf_range(0.5, 0.9),
			randf_range(0.0, 0.15),
			randf_range(0.0, 0.1),
			randf_range(0.08, 0.25)
		)
		rect.position = Vector2(
			randf_range(0, vp_size.x),
			randf_range(0, vp_size.y)
		)
		rect.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(rect)
		move_child(rect, 1)
		particles.append({
			"node": rect,
			"speed": randf_range(5, 18),
			"sway": randf_range(0.3, 1.5),
			"phase": randf_range(0, TAU)
		})

func _update_particles(delta: float) -> void:
	var vp_size = get_viewport().get_visible_rect().size
	for p in particles:
		var node: ColorRect = p["node"]
		node.position.y -= p["speed"] * delta
		node.position.x += sin(time_elapsed * p["sway"] + p["phase"]) * 10.0 * delta
		if node.position.y < -10:
			node.position.y = vp_size.y + 10
			node.position.x = randf_range(0, vp_size.x)

# ── Entrance animation ──

func _animate_entrance() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)

# ── Button callbacks ──

func _on_retry() -> void:
	GameManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/dunia.tscn")

func _on_main_menu() -> void:
	GameManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/gui/main_menu.tscn")
