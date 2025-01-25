class_name Building extends Resource

@export var name: String
@export var mesh: PackedScene
@export var canBePlaced: bool
@export var placeBounds: Array[Vector2i]
@export var hitBounds: Array[Slot]
@export var screws: Array[Screw]


func getSize() -> Vector2i:
	var size := Vector2i.ZERO
	for tile in placeBounds:
		size.x = max(size.x, tile.x)
		size.y = max(size.y, tile.y)
	return size + Vector2i.ONE
