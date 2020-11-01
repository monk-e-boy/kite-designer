# TODO: This should be in a file called LE.gd -- need to re-name some files

#class LE:

const KPlane = preload("KPlane.gd")
const LESection = preload("LESection.gd")

var options = {
	'tube-x-ray': true
}
var spoke_count = 5
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
			'render-inters': false,
			'render-skeleton': false
		},
		#
		# HACK ALERT!!
		#
		false
		#
		# HACK ALERT!!
		#
	)
	# The intersection plane at the centre of the kite is a special case:
	var mid_plane = KPlane.new(
		point + Vector3(0,1,0),
		point + Vector3(0,0,1),
		point + Vector3(0,0,-1)
	)
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
		
		if i == 1:
			opts['tube-radius'] = 0.1
			
		self.add_section(
			self.sections[-1],
			opts
		)

	
	
func add_section(previous_section, options):
	
	# var direction = Vector3(options['length'],0,0)
	# direction = direction.rotated(Vector3(0,1,0), deg2rad(sweep + options['sweep']))
	# direction = direction.rotated(Vector3(0,0,1), deg2rad(angle + options['angle']))
	#var start = previous_section.get_end()
	
	var section = LESection.new(
		false,
		self,
		options,
		previous_section
	)
	
	#
	# ITEM 2
	#
	var v_perp = section.get_perpendicular_vec()
	var plane = previous_section.get_mid_angle(section)
	section.intersects(plane)
	
	self.sections.append(section)

#
# DIRTY HACK
# tell each section that the end point has moved
# TODO -
# each section should know who it is linked
# from - pass this in as a param
# remove 'start pos' as a param
# read start pos from linked_section
# create a dummy previous_section for section_1 to link to
# but while we wait for me to do this - hack it from here
#
# SEE ITEM 2 above
#
func update_sections():
	
	for i in range(1, len(self.sections)):
		var previous_section = self.sections[i-1]
		var start = previous_section.get_end()
		
		self.sections[i].point = start
		self.sections[i].update()
		
		# ITEM 2 to update (see above)
		var plane = previous_section.get_mid_angle(self.sections[i])
		# get tube + skeleton
		self.sections[i].intersects(plane)
	

func get_spoke_count():
	return self.spoke_count
	
func get_section(i):
	return self.sections[i]
	
# pass in section number, get a list of
# [ [vec1, vec2], [vec1, vec2] .... ]
# that describe the tube:
#   from    end_1.spoke_1
#   to      end_2.spoke_1
#
func get_tube_faces(section):
	var i = section
	var ret = []
	
	for spoke in range(self.spoke_count):
		var s1 = self.sections[i+0]
		var v1 = s1.inters[spoke]
	
		var s2 = self.sections[i+1]
		var v2 = s2.inters[spoke]
		
		if v1 and v2:
			ret.append( [v1, v2] )

	return ret 


func get_highlight_plane_section():
	for section in self.sections:
		if section.options['render-plane'] and (not section.plane == null):
			return section
	return false


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
					# SEAM is PURPLE
					surface_tool.add_color(Color8(255,0,255))
				else:
					surface_tool.add_color(Color8(70,70,70))
				# DEBUG CODE
				var a = self.sections[i+0]
				var b = a.inters[j]
				
				var c = self.sections[i+1]
				var d = c.inters[j]
				# END
				if b and d:
					surface_tool.add_vertex(b)
					surface_tool.add_vertex(d)
