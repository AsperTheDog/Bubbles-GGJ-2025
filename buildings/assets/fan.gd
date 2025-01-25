extends BaseBuilding

var direction: BaseBuilding.Orientation


# Called when the node enters the scene tree for the first time.
var fanTween: Tween = null
func _ready() -> void:
	fanTween = create_tween().set_loops()
	fanTween.tween_property($FanFan, "rotation:z", deg_to_rad(360), 0.4)
	fanTween.tween_callback(func(): $FanFan.rotation.z = 0)


func orient(orientation: BaseBuilding.Orientation):
	direction = orientation
	match orientation:
		Orientation.TOP:
			rotate(Vector3.FORWARD, deg_to_rad(-90))
		Orientation.BOTTOM:
			rotate(Vector3.FORWARD, deg_to_rad(90))
		Orientation.RIGHT:
			rotate(Vector3.FORWARD, deg_to_rad(180))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func getMeshes():
	return [$FanPlate, $FanFan]
