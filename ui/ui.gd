class_name UI extends Control

signal elementSelected(index: int) # 0 is deletion tool

@export var selectedColor: Color
@export var unselectedColor: Color

@onready var placeholder: AspectRatioContainer = %Placeholder
@onready var selector: GridContainer = %Selector

var tileSize: float = 1.0

var selected: int = -1:
	set(value):
		if selected == value: return
		setSelected(selected, false)
		selected = value
		setSelected(selected, true)
		elementSelected.emit(selected)


func _ready():
	await get_tree().current_scene.ready
	var count = 1
	for file in DirAccess.get_files_at("res://buildings/definitions"):
		var building: Building = load("res://buildings/definitions/" + file)
		var entry := placeholder.duplicate()
		entry.name = building.name
		entry.get_node("ColorRect").color = unselectedColor
		selector.add_child(entry)
		entry.get_node("Button").pressed.connect(func(): selected = count)
		entry.show()
		if building.mesh != null:
			var buildingSize := building.getSize()
			var zoomOut = max(buildingSize.x * 1.5 * tileSize, buildingSize.y * 1.8 * tileSize)
			var subViewport = entry.get_node("ColorRect/SubViewportContainer/SubViewport")
			var newMesh: BaseBuilding = building.mesh.instantiate()
			newMesh.makePreview(count)
			subViewport.add_child(newMesh)
			var cam: Camera3D = subViewport.get_node("Camera3D")
			cam.cull_mask = 0
			cam.set_cull_mask_value(count + 2, true)
			cam.position.z = zoomOut
			cam.position.x = buildingSize.x * 0.45 * tileSize
			cam.position.y = buildingSize.y * 0.5 * tileSize
			var halfTile = tileSize / 2
			cam.look_at(Vector3(((buildingSize.x - 1) * halfTile), ((buildingSize.y - 1) * halfTile), 0.1))
		else:
			entry.get_node("ColorRect/SubViewportContainer").queue_free()
			entry.get_node("ColorRect/Label").text = building.name
		count += 1


func onUIEntered() -> void:
	get_tree().current_scene.allowScroll = false


func onUIExited() -> void:
	get_tree().current_scene.allowScroll = true


var closed: bool = false
var tween: Tween = null
func toggleDrawer():
	if tween != null:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	var target = $OpenMarker.position.x if closed else $ClosedMarker.position.x
	var leftAnchor = $OpenMarker.anchor_left if closed else $ClosedMarker.anchor_left
	var rightAnchor = 1.0 if closed else $EndMarker.anchor_right
	tween.tween_property($SidePanel, "position:x", target, 0.5)
	tween.tween_property($SidePanel, "anchor_left", leftAnchor, 0.5)
	tween.tween_property($SidePanel, "anchor_right", rightAnchor, 0.5)
	closed = not closed


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drawer"):
		toggleDrawer()


func setSelected(index: int, doSelect: bool):
	if index <= 0: return
	var child: Control = selector.get_child(index)
	var rect: ColorRect = child.get_node("ColorRect")
	rect.color = selectedColor if doSelect else unselectedColor


func selectDemoTool():
	selected = 0
