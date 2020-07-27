extends MeshInstance

func _ready():
	
	var surface_tool = SurfaceTool.new();
	
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	# for details on how/why this works:
	# https://github.com/godotengine/godot/issues/40737
	# https://godotforums.org/discussion/19045/how-do-i-use-spatialmaterial-in-gdscript
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	surface_tool.set_material(mat)
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(1, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, 1, 0));
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(0, 1, 0, 1));
	surface_tool.add_vertex(Vector3(1, 1, 0));
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(0, 0, 1, 1));
	surface_tool.add_vertex(Vector3(0, 3, 0));
	
	surface_tool.add_index(0);
	surface_tool.add_index(1);
	surface_tool.add_index(1);
	surface_tool.add_index(2);
	surface_tool.add_index(2);
	surface_tool.add_index(0);
	
	mesh = surface_tool.commit();


