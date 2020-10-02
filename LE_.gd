# TODO: This should be in a file called LE.gd -- need to re-name some files

#class LE:

const KPlane = preload("KPlane.gd")
const LESection = preload("LESection.gd")

var options = {
	'tube-x-ray': true
}
var spoke_count = 4
var seam_angle = 0
var sections = []


func _init(options):
	for key in options:
		self.options[key] = options[key]
	
	var point = Vector3(0,1,0)
	var direction = Vector3(0.5,0,0)
	var deg1 = -5
	direction = direction.rotated(Vector3(0,0,1), deg2rad(deg1))
	
	var x = Vector3(1,0,0)
	var rot_z = -25.0
	var rot_y = 45.0
	
	
	var sec1 = LESection.new(
		point,
		self,
		{
			'length': 0.5,
			'profile-connection-angle': 270,
			'seam-angle': seam_angle,
			'tube-radius': 0.2,
			'sweep': 5,
			'angle': -5,
			'render-spokes': false,
			'render-rays': false,
			'render-inters': true,
			'render-skeleton': false
		})
	# The intersection plane at the centre of the kite is a special case:
	var mid_plane = KPlane.new(Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,-1))
	sec1.intersects(mid_plane)
	
	self.sections.append(sec1)

	var sweep = 25
	var angle = deg1
	for i in range(5):

		# read from config file
		var opts = {
			'angle': -7,
			'sweep': 20,
			'length': 0.5,
			'profile-connection-angle': 270,
			'seam-angle': seam_angle,
			'tube-radius': 0.2,
			'render-spokes': false,
			'render-rays': false,
			'render-inters': true,
			'render-skeleton': false
		}
		
		# these are relative to previous changes in angle and swwp
		opts['angle'] += angle
		#opts['sweep'] += sweep
		
		if i == 1:
			opts['tube-radius'] = 0.1
	#		opts['sweep'] = 90
	#		opts['angle'] = -45
			
		self.add_section(
			self.sections[-1],
			opts
		)
		
		angle += opts['angle']
		sweep += opts['sweep']
	
	
func add_section(previous_section, options):
	
	# var direction = Vector3(options['length'],0,0)
	# direction = direction.rotated(Vector3(0,1,0), deg2rad(sweep + options['sweep']))
	# direction = direction.rotated(Vector3(0,0,1), deg2rad(angle + options['angle']))
	var start = previous_section.get_end()
	
	var section = LESection.new(
		start,
		self,
		options
	)
	
	var v_perp = section.get_perpendicular_vec()
	var plane = previous_section.get_mid_angle(section)
	section.intersects(plane)
	
	self.sections.append(section)


func get_spoke_count():
	return self.spoke_count

func render(surface_tool):
	# waggle the angle between -90 and +90 degrees
	#	angle += 0.014
	#	angle2 += 0.012
	#	angle3 += 0.009
	#var deg1 = sin(angle) * 120
	#var deg2 = sin(angle2) * 120
	#var deg3 = 90 + sin(angle3) * 90
	
	for s in self.sections:
		s.render(surface_tool)
	
	if self.options['tube-x-ray']:
		for i in range(self.sections.size()-1):
			for j in range(self.spoke_count):
				if j==0:
					surface_tool.add_color(Color8(255,0,255))
				else:
					surface_tool.add_color(Color8(70,70,70))
				surface_tool.add_vertex(self.sections[i+0].inters[j])
				surface_tool.add_vertex(self.sections[i+1].inters[j])
