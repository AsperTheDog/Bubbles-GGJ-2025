extends Node3D

var scene
var canvas: Canvas

signal movedIntoNewPos(canvasPos: Vector2i)

@export var simulationStepTimeMs: int = 350
@export var tickNumber: int

@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var canvasPos: Vector2i = Vector2(0, 0)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene = get_tree().current_scene
	canvas = scene.canvas
	
	var tickLoopTween = create_tween().set_loops()
	tickLoopTween.tween_callback(tick_process).set_delay(simulationStepTimeMs/1000.0)

func tick_process():
	tickNumber += 1
	
	# query canvas for obstacles + fans & decide on moving dir
	var moveDir = get_moving_dir()

	# if hazard collision wait for animation to pop
	var collisionDetected = false
	
	for buildingPlacement in canvas.placements:
		var collisionRes = buildingPlacement.get_collision(canvasPos, moveDir)
		if collisionRes == buildingPlacement.CollisionType.Pop:			
			if moveDir.x != 0:
				move_bubble_horizontal(moveDir.x)
			else:
				move_bubble_vertical(moveDir.y)
			pop(simulationStepTimeMs/3.0)		
			return
		elif collisionRes == buildingPlacement.CollisionType.Block:
			collisionDetected = true
		
	if not collisionDetected or moveDir.x != 0:
		if moveDir.x != 0:
			if collisionDetected:
				move_bubble_vertical(moveDir.y)
			else:
				move_bubble_horizontal(moveDir.x)
		else:
			move_bubble_vertical(moveDir.y)			
		movedIntoNewPos.emit(canvasPos)



func set_position_in_canvas(pos: Vector2i):
	canvasPos = pos
	self.position = Vector3(pos.x * canvas.tileSize, pos.y * canvas.tileSize, canvas.tileSize/8)


# Calculates where bubble should move given a position
func get_moving_dir():
	var fans = []
	var hFans = []
	var vFans = []
	for buildingPlacement in canvas.placements:
		if buildingPlacement.building.name == "Fan":
			fans.append(buildingPlacement)
			if buildingPlacement.orientation == Building.Orientation.LEFT or buildingPlacement.orientation ==  Building.Orientation.RIGHT:
				hFans.append(buildingPlacement)
			else:
				vFans.append(buildingPlacement)
				
			
			
	if fans.is_empty():
		return Vector2i(0,1) 
		
	var moveDir = Vector2i(0,0)
	
	var leftStrength = 0
	var rightStrength = 0
	
	for fan: Canvas.BuildingPlacement in hFans:
		if fan.position.y == canvasPos.y:
			if fan.orientation == Building.Orientation.LEFT:
				if fan.position.x < canvasPos.x and canvasPos.x - fan.position.x <= 3:
					var strength = 4 - (canvasPos.x - fan.position.x)
					if leftStrength < strength:
						leftStrength = strength
			elif fan.orientation == Building.Orientation.RIGHT:
				if fan.position.x > canvasPos.x and fan.position.x - canvasPos.x <= 3:
					var strength = 4 - (fan.position.x - canvasPos.x)
					if rightStrength < strength:
						rightStrength = strength
	
	 		
	if leftStrength != rightStrength:
		if leftStrength > rightStrength:
			return Vector2i(1, 0)
		else:
			return Vector2i(-1, 0)
		
	return Vector2i(0,1) 

# Time in seconds
func pop(timeToPop: float):
	await get_tree().create_timer(timeToPop/1000.0).timeout
	# Play sound
	queue_free()
		
		
var tween: Tween = null
func move_bubble_vertical(dir: int):
	if tween != null:
		tween.kill()
	tween = create_tween()
	
	canvasPos.y += dir
	self.position.y += canvas.tileSize * dir
	mesh.position.y = -canvas.tileSize * dir
	tween.tween_property(mesh, "position:y", 0, simulationStepTimeMs/1000.0) 


func move_bubble_horizontal(dir: int):
	if tween != null:
		tween.kill()
	tween = create_tween()
	
	canvasPos.x += dir
	self.position.x += canvas.tileSize * dir
	mesh.position.x = -canvas.tileSize * dir
	tween.tween_property(mesh, "position:x", 0, 0.35) 
