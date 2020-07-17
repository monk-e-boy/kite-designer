extends MeshInstance

export(SpatialMaterial) var material_minor
export(SpatialMaterial) var material_x
export(SpatialMaterial) var material_y
export(SpatialMaterial) var material_z


func _ready():
	var surface_tool = SurfaceTool.new()
	
	# TODO replace with self.get_mesh
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.set_material(material_minor)
	
	var start = -10
	var stop = 10
	for x in range(start, stop+1):
		# Z
		surface_tool.add_vertex(Vector3(x,0,start))
		surface_tool.add_vertex(Vector3(x,0,stop))
		# X
		surface_tool.add_vertex(Vector3(start,0,x))
		surface_tool.add_vertex(Vector3(stop,0,x))
		
#	for x in range(1, 11):
#		# Z
#		surface_tool.add_vertex(Vector3(x,0,5))
#		surface_tool.add_vertex(Vector3(x,0,-5))
#		# X
#		surface_tool.add_vertex(Vector3(5,0,x))
#		surface_tool.add_vertex(Vector3(-5,0,x))

#	surface_tool.set_material(material_x)
#	surface_tool.add_vertex(Vector3(5,0,0))
#	surface_tool.add_vertex(Vector3(-5,0,0))
	
#	surface_tool.set_material(material_y)
#	surface_tool.add_vertex(Vector3(0,5,0))
#	surface_tool.add_vertex(Vector3(0,-5,0))

#	surface_tool.set_material(material_z)
#	surface_tool.add_vertex(Vector3(0,0,5))
#	surface_tool.add_vertex(Vector3(0,0,-5))
	
	surface_tool.generate_normals()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
	
	
