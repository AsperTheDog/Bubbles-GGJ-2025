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
var currentLevel = 0

func _ready():
	ui.elementSelected.connect(onBuildingSelection)
	ui.startPressed.connect(start)
	ui.tileSize = canvas.tileSize
	canvas.creationFinished.connect(ui.unlockButtons)
	canvas.availableUpdated.connect(ui.updateAvailable)
	canvas.won.connect(won)
	loadLevel(currentLevel)


func _process(delta: float):
	# canvas.updateCenter(camera.position)
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var elems = camera.getCanvasCoord(event.position, canvas.tileSize)
		canvasPos = elems[0]
		canvas.lookingObj = elems[1]
	elif event.is_action_pressed("action"):
		canvas.leftClick(selecting)
	elif event.is_action_pressed("skipLevel"):
		canvas.stop()
		canvas.won.emit()


func getCamera():
	return camera


func loadLevel(index: int):
	if index >= levels.size():
		await Fade.fade(true)
		get_tree().change_scene_to_file("res://Menu.tscn")
		await Fade.fade(false)
		return
	canvas.setLevel(levels[index])
	ui.reloadLevel()
	var halfTile = canvas.tileSize / 2
	camera.canvasMin = -halfTile * Vector2.ONE
	camera.canvasMax = (levels[index].canvasSize * canvas.tileSize) + camera.canvasMin


func onBuildingSelection(index: int):
	selecting = index
	if index > 0:
		canvas.enableConstruction(index)
	elif index == 0:
		canvas.enableDemolition()
	else:
		canvas.disableConstruction()


var simulating: bool = false
func start():
	if not simulating:
		canvas.start()
		ui.start()
	else:
		canvas.stop()
		ui.stop()
	simulating = not simulating
		

func won():
	await ui.winTitle()
	ui.resetWin()
	currentLevel += 1
	loadLevel(currentLevel)
	canvas.stop()
	ui.stop()
	simulating = false
	
