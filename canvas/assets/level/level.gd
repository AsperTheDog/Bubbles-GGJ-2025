class_name Level extends Resource

enum WallType {
	NORMAL,
	SPIKED,
	NONE
}

@export var canvasSize: Vector2i
@export var generatorXOffset: int
@export var gathererXOffset: int
@export var buildings: Array[LevelBuilding]
@export var defaultWall: Level.WallType


func addWalls():
	if defaultWall == Level.WallType.NONE: return
	
	var xVal := 0
	var yVal := 0
	var wall: Building
	if defaultWall == Level.WallType.NORMAL:
		wall = preload("res://buildings/definitions/fence.tres")
	else:
		wall = preload("res://buildings/definitions/spikes.tres")
	for x in canvasSize.x:
		pass
