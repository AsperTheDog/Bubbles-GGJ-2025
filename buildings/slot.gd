class_name Slot extends Resource

enum SlotType {
	FULL,
	TOP,
	RIGHT,
	BOTTOM,
	LEFT
}

@export var position: Vector2i
@export var type: SlotType
