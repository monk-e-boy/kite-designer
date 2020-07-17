extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tube_angle = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var tube_scene = load("res://LeadingEdgeSection.tscn")
	var tube = tube_scene.instance()
	tube.transform.origin = Vector3(0,0,0)
	tube.translate_object_local(Vector3(0,1,0))
	self.add_child(tube)

	var tube2 = tube_scene.instance()
	tube2.transform.origin = Vector3(0,0,0)
	tube2.translate_object_local(Vector3(1,0,0))
	self.add_child(tube2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
