class_name Canvas extends Node3D

@export var canvasElem: PackedScene
@export var tileSize: float = 0.2

@onready var tiles: Node3D = $Board/Tiles
@onready var buildings: Node3D = $Board/Buildings
@onready var areaShape: CollisionShape3D = $Board/Area/Shape

class BuildingPlacement:
	var building: Building
	var position: Vector2i
	var orientation: Building.Orientation
	var bolted: bool
	var hitbox: Area3D

var level: Level

var placements: Array[BuildingPlacement] = []

var screwMesh: PackedScene = preload("res://buildings/assets/screw.glb")
var tackMesh: PackedScene = preload("res://buildings/assets/wood_tack.tscn")

var generator: Building = preload("res://buildings/definitions/generator.tres")

func _process(delta):
	pass

func generate():
	for child in tiles.get_children():
		child.queue_free()
		tiles.remove_child(child)
	for child in buildings.get_children():
		child.queue_free()
		buildings.remove_child(child)
	for x in level.canvasSize.x:
		for y in level.canvasSize.y:
			var elem: Node3D = canvasElem.instantiate()
			elem.position = Vector3(x * tileSize, y * tileSize, 0)
			elem.name = "Canvas (" + str(x) + ", " + str(y) + ")"
			tiles.add_child(elem)
			elem.owner = self
	var halfTile := tileSize / 2
	(areaShape.shape as BoxShape3D).size = Vector3(tileSize * level.canvasSize.x, tileSize * level.canvasSize.y, 0.01)
	(areaShape as CollisionShape3D).position = Vector3(halfTile * level.canvasSize.x, halfTile * level.canvasSize.y, 0) - (halfTile * Vector3(1, 1, 0))
	for building: LevelBuilding in level.buildings:
		placeBuilding(building.building, building.placement, building.orientation, true)
		await get_tree().create_timer(0.05).timeout
	placeBuilding(generator, Vector2i(level.generatorXOffset - 1, -2), Building.Orientation.TOP, true)


func getBuildingOverlaps(building: Building, newPos: Vector2i):
	for placedBuild: BuildingPlacement in placements:
		for bound: Vector2i in placedBuild.building.placeBounds:
			var oldPos := bound + placedBuild.position
			for newBound: Vector2i in building.placeBounds:
				if newBound + newPos == oldPos:
					return placedBuild
	return null


func placeBuilding(building: Building, newPos: Vector2i, orientation: Building.Orientation, isBolted: bool):
	var placement = BuildingPlacement.new()
	placement.building = building
	placement.position = newPos
	placement.orientation = orientation
	placement.bolted = isBolted
	var obj: BaseBuilding = placeObjectInCanvas(building, newPos, placement.bolted, orientation)
	obj.orient(orientation)
	placement.hitbox = obj.get_node("Area3D")
	placements.append(placement)


func placeObjectInCanvas(building: Building, pos: Vector2i, isBolted: bool, orientation: Building.Orientation):
	var obj: BaseBuilding = building.mesh.instantiate()
	obj.building = building
	obj.dupeMaterials()
	buildings.add_child(obj)
	obj.scale = Vector3.ONE * 0.01
	obj.global_position = Vector3(pos.x * tileSize, pos.y * tileSize, 0.5)
	var tween = create_tween()
	tween.tween_property(obj, "scale", Vector3.ONE, 0.2)
	tween.tween_property(obj, "position:z", 0, 0.5)
	tween = create_tween()
	tween.tween_interval(0.3)
	for screw: Screw in building.screws:
		tween.tween_callback(placeScrew.bind(screw, obj, pos, isBolted))
		tween.tween_interval(0.3)
	return obj

func placeScrew(screw: Screw, parent: BaseBuilding, buildingPos: Vector2i, isBolted: bool):
	var scObj = (screwMesh if isBolted else tackMesh).instantiate()
	parent.add_child(scObj)
	scObj.scale = Vector3.ONE * 0.01
	var offset: Vector2 = Vector2.ZERO
	var halfTile = tileSize / 2
	match screw.position:
		Screw.ScrewPosition.TOP_LEFT:
			offset = Vector2(-halfTile, halfTile)
		Screw.ScrewPosition.BOTTOM_LEFT:
			offset = Vector2(-halfTile, -halfTile)
		Screw.ScrewPosition.TOP_RIGHT:
			offset = Vector2(halfTile, halfTile)
		Screw.ScrewPosition.BOTTOM_RIGHT:
			offset = Vector2(halfTile, -halfTile)
	var finalPos := Vector2(screw.coord) * tileSize + offset
	scObj.position = Vector3(finalPos.x, finalPos.y, 0.5)
	var tween = create_tween()
	tween.tween_property(scObj, "scale", Vector3.ONE, 0.2)
	tween.tween_property(scObj, "position:z", 0, 0.5)

func setLevel(newLevel: Level):
	level = newLevel.duplicate(true)
	level.addWalls()
	generate()

func enableConstruction(index: int):
	pass

func disableConstruction():
	pass

func enableDemolition():
	disableConstruction()

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
