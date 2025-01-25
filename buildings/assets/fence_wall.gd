extends BaseBuilding


func getMeshes():
	return [$plate]


func orient(orientation: BaseBuilding.Orientation):
	direction = orientation
	match orientation:
		Orientation.LEFT:
			rotate(Vector3.FORWARD, deg_to_rad(-90))
		Orientation.RIGHT:
			rotate(Vector3.FORWARD, deg_to_rad(90))
		Orientation.BOTTOM:
			rotate(Vector3.FORWARD, deg_to_rad(180))
