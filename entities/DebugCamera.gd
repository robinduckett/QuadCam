extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	$Camera2.transform.origin = $QuadEntity.transform.origin + Vector3(-7.071, 11.144, -9.347)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
