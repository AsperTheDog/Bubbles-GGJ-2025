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
@export var available: Array[UsableBuilding]


func addWalls():
	if defaultWall == Level.WallType.NONE: return
	var xVal := 0
	var yVal := 0
	var wall: Building
	if defaultWall == Level.WallType.NORMAL:
		wall = preload("res://buildings/definitions/fence.tres")
	else:
		wall = preload("res://buildings/definitions/spikes.tres")
		
	var addWall = func(pos: Vector2i, orient: Building.Orientation):
		var levelBuilding: LevelBuilding = LevelBuilding.new()
		levelBuilding.building = wall
		levelBuilding.orientation = orient
		levelBuilding.placement = pos
		buildings.append(levelBuilding)
		
	for x in canvasSize.x:
		var distFromGen = x - generatorXOffset + 2
		if distFromGen > 0 and distFromGen <= 3: continue
		addWall.call(Vector2i(x, 0), Building.Orientation.BOTTOM)
	for y in canvasSize.y:
		addWall.call(Vector2i(canvasSize.x - 1, y), Building.Orientation.RIGHT)
	for x in range(canvasSize.x - 1, -1, -1):
		var distFromGather = x - gathererXOffset
		if distFromGather > 0 and distFromGather <= 2: continue
		addWall.call(Vector2i(x, canvasSize.y - 1), Building.Orientation.TOP)
	for y in range(canvasSize.y - 1, -1, -1):
		addWall.call(Vector2i(0, y), Building.Orientation.LEFT)
		
