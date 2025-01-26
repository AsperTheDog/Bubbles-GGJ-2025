@tool 
extends Node3D

@export var cornerMesh: PackedScene = preload("res://buildings/assets/metalPlates/metalPlateCorner.tscn")
@export var edgeMesh: PackedScene = preload("res://buildings/assets/metalPlates/metalPlateEdge.tscn")
@export var innerMesh: PackedScene = preload("res://buildings/assets/metalPlates/metalPlateInner.tscn")

@export var canvasSize: float = 0.2
@export var parentNode: Node3D
@export var size: Vector2i
@export var generatePlate: bool

func _process(delta: float) -> void:
	if generatePlate:
		generatePlate = false
		regenerateMesh()

func regenerateMesh():
	if size.x < 2 or size.y < 2:
		printerr("Invalid metal plate size: min size = 2x2")
		return
	
	for child in parentNode.get_children():
		child.queue_free()
		parentNode.remove_child(child)
	
	var rotation = 0 # counterClock in degrees
	for x in size.x:
		for y in size.y:
			var obj: Node3D
			if x == 0:
				if y == 0:
					obj = cornerMesh.instantiate()
					rotation = 0
				elif y == size.y -1:
					obj = cornerMesh.instantiate()
					rotation = 270
				else:
					obj = edgeMesh.instantiate()
					rotation = 270
			elif x == size.x -1:
				if y == 0:
					obj = cornerMesh.instantiate()
					rotation = 90
				elif y == size.y -1:
					obj = cornerMesh.instantiate()
					rotation = 180
				else:
					obj = edgeMesh.instantiate()
					rotation = 90
			else: # x <> limits
				if y == 0:
					obj = edgeMesh.instantiate()
					rotation = 0
				elif y == size.y -1:
					obj = edgeMesh.instantiate()
					rotation = 180
				else:
					obj = innerMesh.instantiate()
					rotation = 0
			
			obj.position = Vector3(x * canvasSize, y * canvasSize, 0.05)
			obj.rotate_z(deg_to_rad(rotation))
			parentNode.add_child(obj)
			obj.owner = self
		
	var area = Area3D.new()	
	parentNode.add_child(area)
	area.owner = self
	area.position = Vector3(size.x/4.0 * canvasSize, size.y/4.0 * canvasSize, 0)
	
	var coll = CollisionShape3D.new()
	area.add_child(coll)
	coll.owner = self
	coll.shape = BoxShape3D.new()
	coll.shape.size = Vector3(size.x * canvasSize, size.y * canvasSize, canvasSize)
	
	
