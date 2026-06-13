extends CanvasLayer

@onready var resume_btn: Button = $Center/Panel/VBox/ResumeButton
@onready var menu_btn: Button = $Center/Panel/VBox/MenuButton
@onready var _overlay: ColorRect = $Overlay

func _ready() -> void:
	resume_btn.pressed.connect(_on_resume)
	menu_btn.pressed.connect(_on_main_menu)
	_animate_entrance()

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
