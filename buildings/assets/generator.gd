extends BaseBuilding


var fanTween: Tween = null
func _ready() -> void:
	fanTween = create_tween().set_loops()
	fanTween.tween_property($Fan, "rotation:z", deg_to_rad(360), 0.2)
	fanTween.tween_callback(func(): $Fan.rotation.z = 0)


func makePreview(index: int):
	$Fan.layers = 0
	$Fan.set_layer_mask_value(index + 2, true)
	$LightGreen.layers = 0
	$LightGreen.set_layer_mask_value(index + 2, true)
	$LightRed.layers = 0
	$LightRed.set_layer_mask_value(index + 2, true)
	$PlateGen.layers = 0
	$PlateGen.set_layer_mask_value(index + 2, true)
