extends Node3D

@onready var canvas: Canvas = $Canvas
@onready var camera: MainCamera = $Camera

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var canvasPos = camera.getCanvasCoord(event.position, canvas.tileSize)
		print(canvasPos)
		$debug.position.x = canvasPos.x * canvas.tileSize
		$debug.position.y = canvasPos.y * canvas.tileSize
