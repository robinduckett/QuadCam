extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var settings = get_node("/root/RC").get_settings()

	if settings[2] == 0:
		print("disable bloom")
		(get_node("World/WorldEnvironment") as WorldEnvironment).environment.glow_enabled = false

	if settings[3] == 0:
		print("disable shadows")
		(get_node("World/DirectionalLight") as DirectionalLight).shadow_enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
