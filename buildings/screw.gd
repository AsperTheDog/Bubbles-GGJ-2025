class_name Screw extends Resource

enum ScrewPosition {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT
}

@export var coord: Vector2i
@export var position: ScrewPosition


func rotate(times: int):
	for i in times:
		position = (position + 1) % 4
