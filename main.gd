extends Node3D

@export var levels: Array[Level]

@onready var canvas: Canvas = $Canvas
@onready var camera: MainCamera = $Camera
@onready var ui: UI = $UI

var canvasPos: Vector2i = Vector2i.ZERO
var allowScroll: bool = true


func _ready():
	ui.tileSize = canvas.tileSize
	loadLevel(0)

func _process(delta: float):
	# canvas.updateCenter(camera.position)
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		canvasPos = camera.getCanvasCoord(event.position, canvas.tileSize)

func getCamera():
	return camera


func loadLevel(index: int):
	canvas.setLevel(levels[index])
	var halfTile = canvas.tileSize / 2
	camera.canvasMin = -halfTile * Vector2.ONE
	camera.canvasMax = (levels[index].canvasSize * canvas.tileSize) + camera.canvasMin
