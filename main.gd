extends Node3D

@export var levels: Array[Level]

@onready var canvas: Canvas = $Canvas
@onready var camera: MainCamera = $Camera
@onready var ui: UI = $UI

var canvasPos: Vector2i = Vector2i.MAX:
	set(value):
		if value == canvasPos: return
		canvasPos = value
		canvas.updateGhostPlacement(canvasPos)
var allowScroll: bool = true

var selecting: int = -1


func _ready():
	ui.elementSelected.connect(onBuildingSelection)
	ui.tileSize = canvas.tileSize
	canvas.creationFinished.connect(ui.unlockButtons)
	canvas.availableUpdated.connect(ui.updateAvailable)
	loadLevel(3)


func _process(delta: float):
	# canvas.updateCenter(camera.position)
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var elems = camera.getCanvasCoord(event.position, canvas.tileSize)
		canvasPos = elems[0]
		canvas.lookingObj = elems[1]
	elif event.is_action("action"):
		canvas.leftClick(selecting)


func getCamera():
	return camera


func loadLevel(index: int):
	canvas.setLevel(levels[index])
	ui.reloadLevel()
	var halfTile = canvas.tileSize / 2
	camera.canvasMin = -halfTile * Vector2.ONE
	camera.canvasMax = (levels[index].canvasSize * canvas.tileSize) + camera.canvasMin


func onBuildingSelection(index: int):
	if index > 0:
		canvas.enableConstruction(index)
	elif index == 0:
		canvas.enableDemolition()
	else:
		canvas.disableConstruction()
