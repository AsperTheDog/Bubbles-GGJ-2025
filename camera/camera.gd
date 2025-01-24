class_name MainCamera extends Camera3D

@onready var ray : RayCast3D = $mouseRay

func getCanvasCoord(screenCoord: Vector2, tileSize: float) -> Vector2i:
	var direction := project_ray_normal(screenCoord)
	ray.target_position = direction * 100
	if ray.is_colliding():
		var ret = ray.get_collision_point()
		ret /= tileSize
		return Vector2i(round(ret.x), round(ret.y))
	return Vector2i.MAX
