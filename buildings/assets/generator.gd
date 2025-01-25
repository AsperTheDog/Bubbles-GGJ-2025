extends BaseBuilding


var fanTween: Tween = null
func _ready() -> void:
	fanTween = create_tween().set_loops()
	fanTween.tween_property($Fan, "rotation:z", deg_to_rad(360), 0.2)
	fanTween.tween_callback(func(): $Fan.rotation.z = 0)


func getMeshes():
	return [$Fan, $LightGreen, $LightRed, $PlateGen]
