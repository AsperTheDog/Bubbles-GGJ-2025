class_name Canvas extends Node3D

@export var canvasElem: PackedScene
@export var size: Vector2i
@export var tileSize: float = 0.1

@onready var board: Node3D = $Board/Tiles
@onready var buildings: Node3D = $Board/Buildings
@onready var areaShape: CollisionShape3D = $Board/Area/Shape

class BuildingPlacement:
	var building: Building
	var position: Vector2i
	var hitbox: Area3D

var placements: Array[BuildingPlacement] = []

var screwMesh: PackedScene = preload("res://buildings/assets/screw.glb")

func _ready():
	generate()

func _process(delta):
	pass

func generate():
	for child in board.get_children():
		child.queue_free()
		board.remove_child(child)
	for x in size.x:
		for y in size.y:
			var elem: Node3D = canvasElem.instantiate()
			elem.position = Vector3(x * tileSize, y * tileSize, 0)
			elem.name = "Canvas (" + str(x) + ", " + str(y) + ")"
			board.add_child(elem)
			elem.owner = self
	var halfTile := tileSize / 2
	(areaShape.shape as BoxShape3D).size = Vector3(tileSize * size.x, tileSize * size.y, 0.01)
	(areaShape as CollisionShape3D).position = Vector3(halfTile * size.x, halfTile * size.y, 0) - (halfTile * Vector3(1, 1, 0))


func getBuildingOverlaps(building: Building, newPos: Vector2i):
	for placedBuild: BuildingPlacement in placements:
		for bound: Vector2i in placedBuild.building.placeBounds:
			var oldPos := bound + placedBuild.position
			for newBound: Vector2i in building.placeBounds:
				if newBound + newPos == oldPos:
					return 
	return null


func placeBuilding(building: Building, newPos: Vector2i):
	var placement = BuildingPlacement.new()
	placement.building = building
	placement.position = newPos
	var obj = placeObjectInCanvas(building, newPos)
	placement.hitbox = obj.get_node("Area3D")


func placeObjectInCanvas(building: Building, pos: Vector2i):
	var obj: Node3D = building.mesh.instantiate()
	buildings.add_child(obj)
	obj.scale = Vector3.ZERO
	obj.global_position = Vector3(pos.x * tileSize, pos.y * tileSize, 1)
	var tween = create_tween()
	tween.tween_property(obj, "scale", Vector3.ONE, 0.2)
	tween.tween_property(obj, "position:z", 0, 0.5)
	return obj

func placeScrew(screw: Screw, parent: BaseBuilding):
	var scObj = screwMesh.instantiate()
	parent.add_child(scObj)
	

#region tilt

#signal tiltingUpdate(tilting: bool)
#
#var lastTiltPosition: Vector3
#var isTilting: bool = false:
	#set(value):
		#if isTilting == value:
			#return
		#isTilting = value
		#tiltingUpdate.emit(isTilting)
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion and isTilting:
		#var camera: Camera3D = get_tree().current_scene.getCamera()
		#var direction: Vector3 = camera.project_ray_normal(event.position) + camera.position
		#direction.z = camera.position.z
		#look_at(direction)
#
#func updateCenter(newPos: Vector3):
	#newPos.z = 0
	#position = newPos
	#board.global_position = Vector3.ZERO

#endregion
