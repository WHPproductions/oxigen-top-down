extends CanvasLayer

var font: Font
var heart_nodes: Array[PanelContainer] = []
@onready var score_label: Label = $GameGUI/TopBar/ScorePanel/ScoreRow/ScoreLabel
@onready var score_icon: Label = $GameGUI/TopBar/ScorePanel/ScoreRow/ScoreIcon
var max_hearts: int = 5
var _pause_menu: Node = null

const HEART_FULL := Color("f22633ff")
const HEART_EMPTY := Color(0.25, 0.2, 0.22)
const SCORE_GOLD := Color(1.0, 0.85, 0.0)
const PANEL_BG := Color("0d0d1abf")
const PANEL_BORDER := Color("40477380")

func _ready() -> void:
	font = load("res://scenes/gui/Minecraft.ttf")
	_build_hud()
	GameManager.score_changed.connect(_on_score_changed)
	await get_tree().process_frame
	_connect_hero()

func _connect_hero() -> void:
	var hero = get_tree().get_first_node_in_group("player")
	if hero and hero is Hero:
		hero.health_changed.connect(_on_health_changed)
		hero.died.connect(_on_hero_died)

func _build_hud() -> void:
	# Main margin container for edge padding
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	# Top bar - health on left, score on right
	var top_bar = HBoxContainer.new()
	top_bar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(top_bar)

	# ── Health Panel ──
	var hp_panel = _make_panel()
	top_bar.add_child(hp_panel)

	var hp_row = HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 4)
	hp_panel.add_child(hp_row)

	# "HP" label
	var hp_label = Label.new()
	hp_label.text = "HP"
	hp_label.add_theme_font_override("font", font)
	hp_label.add_theme_font_size_override("font_size", 16)
	hp_label.add_theme_color_override("font_color", Color(0.9, 0.35, 0.4))
	hp_label.add_theme_color_override("font_outline_color", Color(0.3, 0.0, 0.05))
	hp_label.add_theme_constant_override("outline_size", 3)
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_row.add_child(hp_label)

	# Small gap
	var hp_gap = Control.new()
	hp_gap.custom_minimum_size.x = 4
	hp_row.add_child(hp_gap)

	# Heart blocks - pixel-art styled colored panels
	for i in max_hearts:
		var heart = _make_heart()
		hp_row.add_child(heart)
		heart_nodes.append(heart)

	# ── Spacer ──
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer)

	# ── Score Panel ──
	var sc_panel = _make_panel()
	top_bar.add_child(sc_panel)

	var sc_row = HBoxContainer.new()
	sc_row.add_theme_constant_override("separation", 6)
	sc_panel.add_child(sc_row)

	# "SCORE" label
	score_icon = Label.new()
	score_icon.text = "SCORE"
	score_icon.add_theme_font_override("font", font)
	score_icon.add_theme_font_size_override("font_size", 16)
	score_icon.add_theme_color_override("font_color", SCORE_GOLD)
	score_icon.add_theme_color_override("font_outline_color", Color("664d00ff"))
	score_icon.add_theme_constant_override("outline_size", 3)
	score_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sc_row.add_child(score_icon)

	# Score value
	score_label = Label.new()
	score_label.text = "0"
	score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	score_label.add_theme_constant_override("outline_size", 3)
	score_label.custom_minimum_size.x = 40
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sc_row.add_child(score_label)

func _make_panel() -> PanelContainer:
	var p = PanelContainer.new()
	var s = StyleBoxFlat.new()
	s.bg_color = PANEL_BG
	s.border_color = PANEL_BORDER
	s.set_border_width_all(2)
	s.set_corner_radius_all(4)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.shadow_color = Color("00000040")
	s.shadow_size = 2
	s.shadow_offset = Vector2(1, 2)
	p.add_theme_stylebox_override("panel", s)
	return p

func _make_heart() -> PanelContainer:
	var heart = PanelContainer.new()
	heart.custom_minimum_size = Vector2(14, 14)
	var s = StyleBoxFlat.new()
	s.bg_color = HEART_FULL
	s.set_corner_radius_all(2)
	s.border_color = Color("a60d1aff")
	s.set_border_width_all(1)
	heart.add_theme_stylebox_override("panel", s)
	return heart

# ── Signal callbacks ──

func _on_score_changed(score: int) -> void:
	score_label.text = str(score)
	# Flash the score label gold
	var tw = create_tween()
	score_icon.modulate = Color(1.5, 1.3, 0.6)
	tw.tween_property(score_icon, "modulate", Color.WHITE, 0.25)

func _on_health_changed(current: int, maximum: int) -> void:
	# Grow heart array if max HP increased
	while heart_nodes.size() < maximum:
		var heart = _make_heart()
		heart_nodes[0].get_parent().add_child(heart)
		heart_nodes.append(heart)

	for i in heart_nodes.size():
		if i < current:
			heart_nodes[i].modulate = Color.WHITE
		else:
			heart_nodes[i].modulate = Color(0.25, 0.2, 0.22)

	# Animate the last lost heart
	if current >= 0 and current < heart_nodes.size() and current < maximum:
		var lost = heart_nodes[current]
		var tw = create_tween()
		lost.modulate = Color(1.3, 0.5, 0.5)
		tw.tween_property(lost, "modulate", Color(0.25, 0.2, 0.22), 0.35)

func _on_hero_died() -> void:
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/gui/game_over.tscn")

# ── Pause handling ──

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		_show_pause()

func _show_pause() -> void:
	if _pause_menu:
		return
	get_tree().paused = true
	_pause_menu = load("res://scenes/gui/pause_menu.tscn").instantiate()
	_pause_menu.tree_exiting.connect(func(): _pause_menu = null)
	add_child(_pause_menu)
