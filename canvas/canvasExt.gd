extends Node3D

var canvas: Canvas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene = get_tree().current_scene
	await scene.ready
	canvas = scene.canvas


func get_move_dir_at(pos: Vector2i):
	pass
