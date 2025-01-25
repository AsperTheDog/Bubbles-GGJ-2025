class_name Screw extends Resource

enum ScrewPosition {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

@export var coord: Vector2i
@export var position: ScrewPosition
