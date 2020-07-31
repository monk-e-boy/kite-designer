extends MeshInstance


func draw():
	print("Draw")

class T:
	func go(parent):
		parent.draw()

func _ready():
	var t = T.new()
	t.go(self)
