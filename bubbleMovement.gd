extends MeshInstance3D


var verTween: Tween = null
var horTween: Tween = null

@onready var origScale = self.scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale.x = 0.9 * origScale.x
	self.scale.y = 0.9 * origScale.y
	horTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	horTween.tween_property(self, "scale:x", 1.1 * origScale.x, 0.4)
	horTween.tween_property(self, "scale:x", 0.9 * origScale.x, 0.4)
	await get_tree().create_timer(0.2).timeout
	verTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	verTween.tween_property(self, "scale:y", 1.1 * origScale.y, 0.4)
	verTween.tween_property(self, "scale:y", 0.9 * origScale.y, 0.4)
