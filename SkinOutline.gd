extends MeshInstance

export(SpatialMaterial) var material
var _go = false

func _ready():
	pass
	
func go():
	var surface_tool = SurfaceTool.new()
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.set_material(material)
	
	var vecs = []#self.get_parent().debug_vec_pairs
	
	vecs += self.get_parent().strips[0].flatten_strip()
	var tmp_vec_pairs = self.get_parent().strips[1].flatten_strip()
	
	for i in range(tmp_vec_pairs.size()):
		tmp_vec_pairs[i][0] += Vector3(1,0,0)
		tmp_vec_pairs[i][1] += Vector3(1,0,0)
		
	vecs += tmp_vec_pairs
	
	if vecs.size() > 0:
		for pair in vecs:
			surface_tool.add_vertex(pair[0])
			surface_tool.add_vertex(pair[1])
	
	
	# LABEL
	var tmp = vecs[0]
	var lines = Text.strr(self.get_parent().strips[0].label + " LE", Vector3(0.005,0.005,0.005), tmp[0] + (tmp[0]+(tmp[1]-tmp[0])/2 + Vector3(0,0.005,0)))
	for pair in lines:
		surface_tool.add_vertex(pair[0])
		surface_tool.add_vertex(pair[1])
		
	tmp = tmp_vec_pairs[0]
	lines = Text.strr(
			self.get_parent().strips[1].label + " LE",
			Vector3(0.005,0.005,0.005),
			tmp[0]+(tmp[1]-tmp[0])/2 + Vector3(0,0.01,0.1))
	for pair in lines:
		surface_tool.add_vertex(pair[0])
		surface_tool.add_vertex(pair[1])

	surface_tool.generate_normals()
	surface_tool.commit(mesh)
	self.set_mesh(mesh)
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _go:
		return
	
	# TODO: check parent is ready - animations?
	# HACK ALERT:
	if self.get_parent().strips.size() < 1:
		return
		
	go()
	_go = true

func save():
	print("Saving...")
	var x_offset = 0
	
	var content = ""
	content += """<svg xmlns="http://www.w3.org/2000/svg" width="15cm" height="15cm">"""
	content += """<style>line{stroke: black}</style>"""
	# https://stackoverflow.com/questions/30806126/drawing-svg-path-and-polygon-in-cm
#	content += """<g transform="scale(35.43307)">"""

	content += "<line x1=\"0\" y1=\"0\" "
	content += "x2=\"10\" y2=\"10\"/>"
	
	var strips = self.get_parent().strips
	for strip in strips:
		
		var vecs = strip.flatten_strip()
		if vecs.size() > 0:
			for pair in vecs:
				var x1 = pair[0].x *  100 + 30 + x_offset
				var y1 = pair[0].z * -100 + 30
				var x2 = pair[1].x *  100 + 30 + x_offset
				var y2 = pair[1].z * -100 + 30
				content += "<line x1=\""+ str(x1) +"\" y1=\""+ str(y1) +"\" "
				content += "x2=\""+ str(x2) +"\" y2=\""+ str(y2) +"\"/>"
				
			var tmp = vecs[0]
			var lines = Text.str_horizontal(strip.label + " LE", Vector3(0.005,0.005,0.005), tmp[0] + (tmp[0]+(tmp[1]-tmp[0])/2 + Vector3(0,0.005,0)))
			for pair in lines:
				var x1 = pair[0].x *  100 + 30 + x_offset
				var y1 = pair[0].z * -100 + 30
				var x2 = pair[1].x *  100 + 30 + x_offset
				var y2 = pair[1].z * -100 + 30
				
				content += "<line x1=\""+ str(x1) +"\" y1=\""+ str(y1) +"\" "
				content += "x2=\""+ str(x2) +"\" y2=\""+ str(y2) +"\"/>"
		
		x_offset += 200
		
#	content += "<polyline points=\""
#	if vecs.size() > 0:
#		for pair in vecs:
#			content += " " + str(pair[0].x * 100 + 30) +","+ str(pair[0].z * -100 + 30)
#			content += " " + str(pair[1].x * 100 + 30) +","+ str(pair[1].z * -100 + 30)
#	content += "\" style=\"fill:none;stroke:black;stroke-width:1\" />"

#	content += """</g>"""
	content += """</svg>"""

	var file = File.new()
	file.open("user://kite-design-outlines.svg", File.WRITE)
	file.store_string(content)
	file.close()
	print("Saved")


func _on_Button_pressed():
	self.save()
