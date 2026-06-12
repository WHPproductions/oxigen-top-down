extends CanvasLayer

var font: Font
var _overlay: ColorRect

func _ready() -> void:
	font = load("res://scenes/gui/Minecraft.ttf")
	_build_ui()
	_animate_entrance()

func _build_ui() -> void:
	# ── Dark overlay ──
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.0, 0.0, 0.04, 0.7)
	add_child(_overlay)

	# ── Centered panel ──
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.06, 0.1, 0.95)
	panel_style.border_color = Color(0.3, 0.35, 0.5, 0.6)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 44
	panel_style.content_margin_right = 44
	panel_style.content_margin_top = 32
	panel_style.content_margin_bottom = 32
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	# ── PAUSED title ──
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9))
	title.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.2))
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# ── Divider ──
	var divider = ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 2)
	divider.color = Color(0.3, 0.35, 0.5, 0.4)
	vbox.add_child(divider)

	# ── Gap ──
	var gap = Control.new()
	gap.custom_minimum_size.y = 6
	vbox.add_child(gap)

	# ── Buttons ──
	var resume_btn = _create_button("RESUME", Color(0.2, 0.8, 0.5))
	resume_btn.pressed.connect(_on_resume)
	vbox.add_child(resume_btn)

	var menu_btn = _create_button("MAIN MENU", Color(0.7, 0.4, 0.4))
	menu_btn.pressed.connect(_on_main_menu)
	vbox.add_child(menu_btn)

func _create_button(text: String, accent: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(200, 0)

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent, 0.1)
	normal.border_color = Color(accent, 0.4)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(5)
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", normal)

	var hover = normal.duplicate()
	hover.bg_color = Color(accent, 0.22)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = normal.duplicate()
	pressed.bg_color = Color(accent, 0.35)
	btn.add_theme_stylebox_override("pressed", pressed)

	var focus = normal.duplicate()
	focus.border_color = accent
	btn.add_theme_stylebox_override("focus", focus)

	btn.add_theme_color_override("font_color", Color(accent, 0.85))
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)

	return btn

# ── Entrance animation ──

func _animate_entrance() -> void:
	_overlay.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.15)

# ── Input ──

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_resume()
		get_viewport().set_input_as_handled()

# ── Button callbacks ──

func _on_resume() -> void:
	get_tree().paused = false
	queue_free()

func _on_main_menu() -> void:
	get_tree().paused = false
	GameManager.reset_score()
	get_tree().change_scene_to_file("res://scenes/gui/main_menu.tscn")
