class_name UI extends Control

signal elementSelected(index: int) # 0 is deletion tool
signal startPressed

@export var selectedColor: Color
@export var unselectedColor: Color

@onready var placeholder: TextureRect = %Placeholder
@onready var selector: GridContainer = %Selector

var tileSize: float = 1.0

var selected: int = -1:
	set(value):
		setSelected(selected, false)
		if selected == value:
			selected = -1
		else:
			selected = value
		setSelected(selected, true)
		elementSelected.emit(selected)


func _ready():
	await get_tree().create_timer(0.2).timeout
	Fade.fade(false)


func reloadLevel():
	for elem in selector.get_children():
		if elem == placeholder: continue
		elem.queue_free()
		selector.remove_child(elem)
	var count = 1
	for element: UsableBuilding in get_tree().current_scene.canvas.level.available:
		if not element.building.canBePlaced: continue
		var entry := placeholder.duplicate()
		entry.name = element.building.name
		selector.add_child(entry)
		entry.texture = entry.texture.duplicate()
		setSelected(selector.get_child_count() - 1, false)
		updateAvailable(count)
		entry.get_node("Button").pressed.connect(func(): selected = count)
		entry.show()
		var buildingSize := element.building.getSize()
		var zoomOut = max(buildingSize.x * 1.5 * tileSize, buildingSize.y * 1.8 * tileSize)
		var subViewport = entry.get_node("SubViewportContainer/SubViewport")
		var newMesh: BaseBuilding = element.building.mesh.instantiate()
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
		count += 1
	lockButtons()


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
	var child: TextureRect = selector.get_child(index)
	child.self_modulate = selectedColor if doSelect else unselectedColor


func selectDemoTool():
	selected = 0


func lockButtons():
	$Start.disabled = true
	$DeleteElem/TextureButton.disabled = true
	for elem in selector.get_children():
		if elem == placeholder: continue
		elem.get_node("Button").disabled = true


func unlockButtons():
	$Start.disabled = false
	$DeleteElem/TextureButton.disabled = false
	for elem in selector.get_children():
		if elem == placeholder: continue
		elem.get_node("Button").disabled = false


func updateAvailable(index: int):
	var entry  = selector.get_child(index)
	var element = get_tree().current_scene.canvas.level.available[index - 1]
	entry.get_node("Label").text = str(element.amount)
	if element.amount == 0:
		entry.get_node("Button").disabled = true
		selected = -1
	else:
		entry.get_node("Button").disabled = false


func onStartPressed():
	startPressed.emit()


func start():
	$Start.text = "STOP"
	lockButtons()
	$Start.disabled = false


func stop():
	$Start.text = "START"
	unlockButtons()


func winTitle():
	$ColorRect2.show()
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops(2)
	$ColorRect2/RichTextLabel.modulate.a = 0.0
	tween.tween_property($ColorRect2/RichTextLabel, "modulate:a", 1.0, 0.5)
	tween.tween_property($ColorRect2/RichTextLabel, "modulate:a", 0.0, 0.5)
	selected = -1
	return tween.finished

func resetWin():
	$ColorRect2.hide()
