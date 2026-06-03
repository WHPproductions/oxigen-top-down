extends CanvasLayer

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)

func _on_score_changed(score: int) -> void:
	$Label.text = str(score)
