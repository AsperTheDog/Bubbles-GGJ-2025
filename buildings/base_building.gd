class_name BaseBuilding extends Node3D

var direction: Building.Orientation
var building: Building

var overlayMesh: MeshInstance3D

var overlayMat: StandardMaterial3D = preload("res://buildings/assets/overlay_material.tres")

@onready var buildSFXEmitter: FmodEventEmitter3D = $BuildSFX

func initialize():
	dupeMaterials()
	var newMesh = MeshInstance3D.new()
	newMesh.mesh = BoxMesh.new()
	var box: BoxMesh = newMesh.mesh
	box.size = $Area3D/CollisionShape3D.shape.size
	newMesh.position = $Area3D/CollisionShape3D.position
	newMesh.material_override = overlayMat.duplicate()
	add_child(newMesh)
	overlayMesh = newMesh
	setOverlayColor(Color.TRANSPARENT)


func dupeMaterials():
	for mesh: MeshInstance3D in getMeshes():
		mesh.material_override = mesh.get_active_material(0).duplicate()


func setOverlayColor(color: Color):
	overlayMesh.material_override.albedo_color = color


func orient(orientation: Building.Orientation):
	direction = orientation
	while orientation != building.baseOrient:
		rotate(Vector3.FORWARD, deg_to_rad(90))
		orientation = (orientation + 1) % 4


func makePreview(index: int):
	for mesh: MeshInstance3D in getMeshes():
		mesh.layers = 0
		mesh.set_layer_mask_value(index + 2, true)


func makeGhost():
	removeHitbox()
	for mesh: MeshInstance3D in getMeshes():
		var mat: StandardMaterial3D = mesh.get_active_material(0)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.0, 1.0, 0.0, 0.7)


func getMeshes():
	return []


func removeHitbox():
	$Area3D.queue_free()
	remove_child($Area3D)

func playBuildSound():
	if(buildSFXEmitter):
		buildSFXEmitter.play()
