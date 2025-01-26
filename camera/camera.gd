class_name MainCamera extends Camera3D

@onready var ray: RayCast3D = $mouseRay
@onready var ray2: RayCast3D = $mouseRay2
@onready var minZ: float = 0.4
@onready var maxZ: float = 2.0
@onready var varZ: float = 0.95

var lookingCoords: Vector2i
var isDragging: bool = false

var canvasMin: Vector2 = Vector2.ZERO
var canvasMax: Vector2 = Vector2.ONE


func _process(delta):
	isDragging = Input.is_action_pressed("drag")

func getCanvasCoord(screenCoord: Vector2, tileSize: float):
	var direction := project_ray_normal(screenCoord)
	ray.target_position = direction * 100
	ray2.target_position = ray.target_position
	var object: BaseBuilding = null
	if ray2.is_colliding():
		var area: Node3D = ray2.get_collider()
		if area != null:
			object = area.owner
	if ray.is_colliding():
		var ret = ray.get_collision_point()
		ret /= tileSize
		return [Vector2i(round(ret.x), round(ret.y)), object]
	return [Vector2i.MAX, object]

func _input(event: InputEvent) -> void:
	var allowScroll = get_tree().current_scene.allowScroll
	if event.is_action("zoomIn") and allowScroll:
		position.z = max(minZ, position.z * varZ)
	elif event.is_action("zoomOut") and allowScroll:
		position.z = min(maxZ, position.z / varZ)
	if event is InputEventMouseMotion and isDragging:
		position.x = clamp(position.x - (event as InputEventMouseMotion).relative.x * 0.0015 * position.z, canvasMin.x, canvasMax.x)
		position.y = clamp(position.y + (event as InputEventMouseMotion).relative.y * 0.0015 * position.z, canvasMin.y, canvasMax.y)
