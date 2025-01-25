extends Node3D

@onready var canvas: Canvas = $Canvas
@onready var camera: MainCamera = $Camera
@onready var ui: UI = $UI

var canvasPos: Vector2i = Vector2i.ZERO
var allowScroll: bool = true


func _ready():
	var halfTile = canvas.tileSize / 2
	camera.canvasMin = -halfTile * Vector2.ONE
	camera.canvasMax = (canvas.size * canvas.tileSize) + camera.canvasMin
	ui.tileSize = canvas.tileSize

func _process(delta: float):
	# canvas.updateCenter(camera.position)
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		canvasPos = camera.getCanvasCoord(event.position, canvas.tileSize)
	if event.is_action_pressed("debug"):
		var gen = preload("res://buildings/definitions/fan.tres")
		canvas.placeBuilding(gen, Vector2i.ONE * 3, BaseBuilding.Orientation.LEFT)

func getCamera():
	return camera
