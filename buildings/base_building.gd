class_name BaseBuilding extends Node3D

var overlayMat: StandardMaterial3D = preload("res://buildings/assets/overlay_material.tres")

var direction: Building.Orientation
var building: Building


func initialize():
	dupeMaterials()
	for mesh:MeshInstance3D in getMeshes():
		mesh.material_overlay = overlayMat


func dupeMaterials():
	for mesh: MeshInstance3D in getMeshes():
		mesh.material_override = mesh.get_active_material(0).duplicate()


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
	for mesh: MeshInstance3D in getMeshes():
		var mat: StandardMaterial3D = mesh.get_active_material(0)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.0, 1.0, 0.0, 0.7)


func getMeshes():
	pass
