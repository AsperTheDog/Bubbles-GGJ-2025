@tool
class_name Canvas extends Node3D

@export var canvasElem: PackedScene
@export var size: Vector2i
@export var tileSize: float = 0.1
@export var regenerate: bool:
	set(value):
		regenerate = false
		generate()

var lookingCoords: Vector2i

func generate():
	for child in get_children():
		if child is Area3D: continue
		child.queue_free()
		remove_child(child)
	for x in size.x:
		for y in size.y:
			var elem: Node3D = canvasElem.instantiate()
			elem.position = Vector3(x * tileSize, y * tileSize, 0)
			elem.name = "Canvas (" + str(x) + ", " + str(y) + ")"
			add_child(elem)
			elem.owner = self
	var halfTile := tileSize / 2
	($Area/Shape.shape as BoxShape3D).size = Vector3(tileSize * size.x, tileSize * size.y, 0.01)
	($Area/Shape as CollisionShape3D).position = Vector3(halfTile * size.x, halfTile * size.y, 0) - (halfTile * Vector3(1, 1, 0))
