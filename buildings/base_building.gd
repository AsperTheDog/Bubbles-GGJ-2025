class_name BaseBuilding extends Node3D

enum Orientation {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}


func dupeMaterials():
	for mesh: MeshInstance3D in getMeshes():
		mesh.material_override = mesh.get_active_material(0).duplicate()


func orient(orientation: BaseBuilding.Orientation):
	pass


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
