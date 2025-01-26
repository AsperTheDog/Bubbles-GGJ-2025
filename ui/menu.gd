extends Control

@onready var start: Button = $CenterContainer/VBoxContainer/Start
@onready var quit: Button = $CenterContainer/VBoxContainer/Quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect(_start)
	quit.pressed.connect(_quit)
	
	pass # Replace with function body.

func _start() -> void:
	pass

func _quit() -> void:
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
