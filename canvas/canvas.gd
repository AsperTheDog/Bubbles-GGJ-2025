class_name Canvas extends Node3D

signal creationFinished
signal availableUpdated(index: int)

@export var canvasElem: PackedScene
@export var tileSize: float = 0.2

@export_group("Colors")
@export var untouchableColor: Color
@export var correctColor: Color
@export var incorrectColor: Color

@onready var tiles: Node3D = $Board/Tiles
@onready var buildings: Node3D = $Board/Buildings
@onready var areaShape: CollisionShape3D = $Board/Area/Shape

enum Mode {BUILDING, DESTROYING, NONE}
var mode: Mode = Mode.NONE
var canDestroy: bool = false
var lookingObj: BaseBuilding = null:
	set(value):
		if value == lookingObj: return
		updateLookingObj(lookingObj, value)
		lookingObj = value
		if lookingObj == null: 
			canDestroy = false
			return
		var placement: BuildingPlacement = getPlacement(lookingObj)
		canDestroy = not placement.bolted if placement != null else false


class BuildingPlacement:
	var building: Building
	var position: Vector2i
	var orientation: Building.Orientation
	var bolted: bool
	var mesh: BaseBuilding

var level: Level

var placements: Array[BuildingPlacement] = []

var screwMesh: PackedScene = preload("res://buildings/assets/screw.tscn")
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
		await get_tree().create_timer(0.02).timeout
	placeBuilding(generator, Vector2i(level.generatorXOffset - 1, -2), Building.Orientation.TOP, true)
	await get_tree().create_timer(0.5).timeout
	creationFinished.emit()


func doesBuildingOverlap(building: BuildingPlacement,newBuilding: Building, newPos: Vector2i):
	for bound: Vector2i in building.building.placeBounds:
			var oldPos := bound + building.position
			for newBound: Vector2i in newBuilding.placeBounds:
				if newBound + newPos == oldPos:
					return true
	return false


func getBuildingOverlaps(building: Building, newPos: Vector2i):
	var elems: Array[BuildingPlacement] = []
	for placedBuild: BuildingPlacement in placements:
		if doesBuildingOverlap(placedBuild, building, newPos):
			elems.append(placedBuild)
	return elems


func removeBuilding():
	if lookingObj == null: return -1
	var index = level.getAvailableIndex(lookingObj.building)
	level.available[index].amount += 1
	if index == -1: return -1
	var placement = getPlacement(lookingObj)
	placements.erase(placement)
	if placement in incorrects:
		incorrects.erase(placement)
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(lookingObj, "scale", Vector3.ZERO, 0.2)
	var lookingObjRef = lookingObj
	tween.tween_callback(func(): lookingObjRef.queue_free())
	lookingObj.removeHitbox()
	lookingObj = null
	return index + 1


func placeBuilding(building: Building, newPos: Vector2i, orientation: Building.Orientation, isBolted: bool):
	var placement = BuildingPlacement.new()
	placement.building = building
	placement.position = newPos
	placement.orientation = orientation
	placement.bolted = isBolted
	var obj: BaseBuilding = placeObjectInCanvas(building, newPos, placement.bolted, orientation)
	obj.orient(orientation)
	placement.mesh = obj
	placements.append(placement)


func getGlobalPos(canvasPos: Vector2i, z: float):
	return Vector3(canvasPos.x * tileSize, canvasPos.y * tileSize, z)


func placeObjectInCanvas(building: Building, pos: Vector2i, isBolted: bool, orientation: Building.Orientation):
	var obj: BaseBuilding = building.mesh.instantiate()
	obj.building = building
	obj.initialize()
	buildings.add_child(obj)
	obj.scale = Vector3.ONE * 0.01
	obj.global_position = getGlobalPos(pos, 0.5)
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
	disableConstruction()
	mode = Mode.BUILDING
	var building: BaseBuilding = level.available[index - 1].building.mesh.instantiate()
	building.building = level.available[index - 1].building
	building.initialize()
	ghostPlacement = building
	ghostPlacement.removeHitbox()
	ghostPlacement.hide()
	buildings.add_child(building)

func disableConstruction():
	mode = Mode.NONE
	if ghostPlacement != null:
		ghostPlacement.queue_free()
	ghostPlacement = null
	for elem: BaseBuilding in buildings.get_children():
		elem.setOverlayColor(Color.TRANSPARENT)

func enableDemolition():
	disableConstruction()
	mode = Mode.DESTROYING
	for building: BuildingPlacement in placements:
		if building.bolted:
			building.mesh.setOverlayColor(untouchableColor)


func getPlacement(obj: BaseBuilding):
	for elem in placements:
		if elem.mesh == obj:
			return elem
	return null


func updateLookingObj(old: BaseBuilding, new: BaseBuilding):
	match mode:
		Mode.DESTROYING:
			if new != null:
				var placement: BuildingPlacement = getPlacement(new)
				if placement != null:
					new.setOverlayColor(correctColor if not placement.bolted else incorrectColor)
			if old != null:
				var placement: BuildingPlacement = getPlacement(old)
				if placement != null:
					old.setOverlayColor(Color.TRANSPARENT if not placement.bolted else untouchableColor)


var chosenOrient: Building.Orientation = Building.Orientation.LEFT:
	set(value):
		if value == chosenOrient: return
		chosenOrient = value
		if ghostPlacement == null: return
		ghostPlacement.orient(chosenOrient)
var lastPos: Vector2i = Vector2i.MAX
var ghostPlacement: BaseBuilding = null
var canPlaceGhost: bool = false
var incorrects: Array[BuildingPlacement]
func updateGhostPlacement(pos: Vector2i):
	if ghostPlacement == null: 
		canPlaceGhost = false
		return
	if pos == Vector2i.MAX:
		ghostPlacement.hide()
		canPlaceGhost = false
		return
	else:
		ghostPlacement.show()
	ghostPlacement.global_position = getGlobalPos(pos, 0)
	var overlaps: Array[BuildingPlacement] = getBuildingOverlaps(ghostPlacement.building, pos)
	canPlaceGhost = overlaps.is_empty()
	for elem in incorrects:
		elem.mesh.setOverlayColor(Color.TRANSPARENT)
	if overlaps.is_empty():
		ghostPlacement.setOverlayColor(correctColor)
		canPlaceGhost = true
	else:
		ghostPlacement.setOverlayColor(incorrectColor)
		canPlaceGhost = false
		for elem: BuildingPlacement in overlaps:
			elem.mesh.setOverlayColor(incorrectColor)
		incorrects = overlaps
	lastPos = pos


func leftClick(index: int):
	match mode:
		Mode.BUILDING:
			if index <= 0 or not canPlaceGhost: return
			placeBuilding(ghostPlacement.building, lastPos, chosenOrient, false)
			level.available[index - 1].amount -= 1
			availableUpdated.emit(index)
			updateGhostPlacement(lastPos)
		Mode.DESTROYING:
			if lookingObj == null or not canDestroy: return
			var idx = removeBuilding()
			if idx == -1: return
			availableUpdated.emit(idx)


func rotateGhost():
	chosenOrient = (chosenOrient + 3) % 4


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate"):
		rotateGhost()
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
