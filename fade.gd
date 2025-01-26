extends Control


func _ready():
	$CanvasLayer/fade.color.a = 0.0


func fade(out: bool):
	var tween: Tween = create_tween()
	$CanvasLayer/fade.color.a = 0.0 if out else 1.0
	tween.tween_property($CanvasLayer/fade, "color:a", 1.0 if out else 0.0, 0.5)
	return tween.finished
