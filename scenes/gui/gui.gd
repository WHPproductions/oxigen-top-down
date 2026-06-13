extends CanvasLayer

var font: Font
@onready var heart_nodes: Array[PanelContainer] = [$Margin/TopBar/HealthPanel/HpRow/Heart1, $Margin/TopBar/HealthPanel/HpRow/Heart2, $Margin/TopBar/HealthPanel/HpRow/Heart3, $Margin/TopBar/HealthPanel/HpRow/Heart4, $Margin/TopBar/HealthPanel/HpRow/Heart5]
@onready var score_label: Label = $Margin/TopBar/ScorePanel/ScoreRow/ScoreLabel
@onready var score_icon: Label = $Margin/TopBar/ScorePanel/ScoreRow/ScoreIcon
var max_hearts: int = 5
var _pause_menu: Node = null

const HEART_FULL := Color("f22633ff")
const HEART_EMPTY := Color(0.25, 0.2, 0.22)

func _ready() -> void:
	font = load("res://scenes/gui/Minecraft.ttf")
	GameManager.score_changed.connect(_on_score_changed)
	await get_tree().process_frame
	_connect_hero_to_signals()

func _connect_hero_to_signals() -> void:
	var hero = get_tree().get_first_node_in_group("player")
	if hero and hero is Hero:
		hero.health_changed.connect(_on_health_changed)
		hero.died.connect(_on_hero_died)

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
