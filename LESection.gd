##class LESection:

const KPlane = preload("KPlane.gd")


var point = Vector3(0,0,0)
var direction = Vector3(0,0,0)
var prof_conn = Vector3(0,0,0)
var seam = Vector3(0,0,0)
var color = Color8(147, 0, 150)
var spokes = []
var ray = Vector3(0,0,0)
var plane = null
# intersects - I've named it inters because I'm an F1 fan
var inters = []
var parent = null
var options = {
	'length': 1,
	'tube-radius': 0.2,
	'render-spokes': false,
	'render-rays': false,
	'render-inters': false,
	'render-plane': false,
	'render-skeleton': true
}
var tmp_v_perp = 0
var tmp_new_angle = 0
var inter_colour = Color8(70,70,70)
var inter_colour_highlighted = Color8(255,0,0)
var is_highlighted = false

var prev_section = false


func _init(point, parent, options, previous_section):
	if previous_section:
		self.point = previous_section.get_end()
	else:
		#
		# HACK for the very first section that needs a point
		# TODO - fix this
		#
		self.point = point
		
	self.parent = parent
	self.prev_section = previous_section

	# merge options with defaults:	
	for key in options:
		self.options[key] = options[key]
		
	self.update()
		
func update():
	
	var direction = Vector3(self.options['length'],0,0)
	# pivot around vertical to sweep back
	var sweep = self.get_calculated_sweep()
	direction = direction.rotated(Vector3(0,1,0), deg2rad(sweep))
	
	# pivot around Z to angle down (mid is horizontal, tips are almost vertical)
	var angle = self.get_calculated_angle()
	direction = direction.rotated(Vector3(0,0,1), deg2rad(angle))
	
	# apply the same transforms to the profile connection point on the LE
	# tube this is marked for sewing
	var prof_conn = Vector3(0,options['tube-radius'],0)
	prof_conn = prof_conn.rotated(Vector3(1,0,0), deg2rad(self.options['profile-connection-angle']))
	prof_conn = prof_conn.rotated(Vector3(0,1,0), deg2rad(self.options['sweep']))
	#prof_conn = prof_conn.rotated(Vector3(0,0,1), deg2rad(self.options['angle']))
	prof_conn = prof_conn.rotated(Vector3(0,0,1), deg2rad(self.get_calculated_angle()))
	
	# apply the same transforms to the LE seam - this is used when we
	# flatten the LE tube. The seam is where we 'cut' the tube before
	# flattening it
	var seam = Vector3(0,options['tube-radius'],0)
	seam = seam.rotated(Vector3(1,0,0), deg2rad(self.options['seam-angle']))
	seam = seam.rotated(Vector3(0,1,0), deg2rad(self.options['sweep']))
	#seam = seam.rotated(Vector3(0,0,1), deg2rad(self.options['angle']))
	seam = seam.rotated(Vector3(0,0,1), deg2rad(self.get_calculated_angle()))
	
	self.direction = direction
	self.prof_conn = prof_conn
	self.seam = seam
	
	#
	self.make_spokes()
	self.make_ray()
	#

func get_calculated_angle():
	# HACK - this should dissapear when I fix how the first section
	#        has a previous section ... maybe?	
	if self.prev_section:
		return self.options['angle'] + self.prev_section.get_calculated_angle()
	else:
		return self.options['angle']


func get_calculated_sweep():
	# HACK - this should dissapear when I fix how the first section
	#        has a previous section ... maybe?	
	if self.prev_section:
		return self.options['sweep'] + self.prev_section.get_calculated_sweep()
	else:
		return self.options['sweep']

#func get_mid_angle(sec: LESection):
func get_mid_angle(sec):
	var a = self.point
	var b = self.point + self.direction
	var c = sec.point + sec.direction

	# HACK - SKELETON HACK
#		surface_tool.add_color(self.color);
#		surface_tool.add_vertex(a)
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(b)
	
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(b)
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(c)

	# b points towards the joint - flip b so it points away
	# move both vectors to the origin
	var v1 = (b-a) * -1
	#surface_tool.add_color(Color8(0,0,0))
	#surface_tool.add_vertex(Vector3(0,0,0))
	#surface_tool.add_color(Color8(0,0,0))
	#surface_tool.add_vertex(v1)
	
	var v2 = c-b
	#surface_tool.add_color(Color8(0,0,0))
	#surface_tool.add_vertex(Vector3(0,0,0))
	#surface_tool.add_color(Color8(0,0,0))
	#surface_tool.add_vertex(v2)
	
	var end_n = v1.normalized() + v2.normalized()
	#surface_tool.add_color(Color8(255,0,0))
	#surface_tool.add_vertex(Vector3(0,0,0))
	#surface_tool.add_color(Color8(255,0,0))
	#surface_tool.add_vertex(end_n)
	
	var cross = v1.cross(v2)
	if cross==Vector3(0,0,0):
		#
		# WARNING - this does not work
		#
		# the two lines are in alignment - rotate by 90 deg
		var tmp = c-b
		# we rotate around z because
		end_n = tmp.rotated(Vector3(0,0,1), deg2rad(90))
		cross = tmp.rotated(Vector3(0,1,0), deg2rad(90))

	#return KPlane.new(b+end_n, b, b+cross) # clockwise order
	return KPlane.new(b+cross, b, b+end_n) # clockwise order

# https://stackoverflow.com/questions/11132681/what-is-a-formula-to-get-a-vector-perpendicular-to-another-vector
func get_perpendicular_vec():
	var x = self.direction.x
	var y = self.direction.y
	var z = self.direction.z
	var v_perp = Vector3(0,0,0)
	if z<x :
		v_perp = Vector3(y,-x,0)
	else:
		v_perp = Vector3(0,-z,y)
	return v_perp
	
func get_end():
	return self.point+self.direction

# used to generate the circle of the tube
# this is then projected back onto the plane
# using rays
func make_spokes():
	
	# this vector is in a random direction
	var v_perp = self.get_perpendicular_vec()
	
	var dir_norm = self.direction.normalized()
	# WHY - we want to eliminate twist in the LE
	# if the ends are made up of 100 points, one end has point 0 at the bottom
	# the other end point 0 is at the top we will get a bow tie.
	#
	# TODO - Need to figure out what angle we want here
	#        Do we want the closes Z to the AoA ?
	# Point 0 projected down to the plane will hit the LE/profile join angle
	#
	var min_z = -100000
	var perp_rotated = 0
	var angle = 0
	for i in range(360):
		var c = v_perp.rotated(dir_norm, deg2rad(i))
		c = c.normalized()
		# make this vector / debug line long enough to see
		c *= self.options['tube-radius'] * 1.2
		if min_z < c.z:
			min_z = c.z
			perp_rotated = c
			angle = i
	
	self.tmp_v_perp = v_perp
	self.tmp_new_angle = perp_rotated
	v_perp = self.get_perpendicular_vec()
	#
	#
	#
	
	#
	# TEMP investigations - - - ignore above
	#
	self.spokes = []
	v_perp = self.seam
	var spoke_count = self.parent.get_spoke_count()
	for i in range(spoke_count):
		#var tmp = (360.0 / spoke_count) * i
		#var c = v_perp.rotated(dir_norm, deg2rad( angle + (360.0 / spoke_count) * i))
		var c = v_perp.rotated(dir_norm, deg2rad((360.0 / spoke_count) * i))
		c = c.normalized()
		c *= self.options['tube-radius']
		self.spokes.append(c)

func make_ray():
	# flip the direction to point back towards the join
	# make it long enough to pierce the plane (* -3)
	# it is possible that the ray and plane do not intersect (strange angles)
	# with a short section length, a tight angle and a large tube diameter
	# the spokes may cross the plane, shooting the ray away from the plane
	# a designer would avoid this as the kite would be shit
	self.ray = self.direction * -3
	
#func intersects(plane:KPlane):
func intersects(plane):
	self.inters = []
	# let's keep a reference to the plane
	self.plane = plane
	for spoke in self.spokes:
		var inter = plane.intersects_ray(
			self.get_end() + spoke,
			self.ray
		)
	
		self.inters.append(inter)

func set_highlighted(h):
	self.is_highlighted = h
	self.options['render-plane'] = h
	self.options['render-spokes'] = h
	
	
func set_angle(a):
	self.options['angle'] = a
	# rebuild the section (bone, joint, inters, etc)
	self.update()

func get_angle():
	return self.options['angle']
	
func set_sweep(a):
	self.options['sweep'] = a
	self.update()

func get_sweep():
	return self.options['sweep']

func render(surface_tool):
	if self.options['render-skeleton']:
		surface_tool.add_color(self.color)
		surface_tool.add_vertex(self.point)
		surface_tool.add_color(self.color)
		surface_tool.add_vertex(self.get_end())
		
	#
	# rotate the projected circle
#		surface_tool.add_color(Color8(0,0,255))
#		surface_tool.add_vertex(self.get_end())
#		surface_tool.add_color(Color8(0,0,255))
#		surface_tool.add_vertex(self.get_end() + self.tmp_v_perp)
	#
#		surface_tool.add_color(Color8(0,0,0))
#		surface_tool.add_vertex(self.get_end())
#		surface_tool.add_color(Color8(0,0,0))
#		surface_tool.add_vertex(self.get_end() + self.tmp_new_angle)
	#
	#
	#
	
	# the plane we are projecting the LE tube onto
	if self.options['render-plane'] and (not self.plane == null):
		self.plane.render(surface_tool)
	
	# spokes of the LE tube radius
	if self.options['render-spokes']:
		# seam vector - just a little white nub
		surface_tool.add_color(Color8(255,255,255))
		surface_tool.add_vertex(self.get_end()+self.seam)
		surface_tool.add_color(Color8(255,255,255))
		surface_tool.add_vertex(self.get_end()+(self.seam*1.1))

		var first = true
		for spoke in self.spokes:
			# draw spokes
			var c = Color8(255,0,0)
			if first:
				c = Color8(0,0,0) # the seam spoke
				first = false
			surface_tool.add_color(c)
			surface_tool.add_vertex(self.get_end())
			surface_tool.add_color(c)
			surface_tool.add_vertex(self.get_end() + spoke)
	
	# the rays from the spokes we project onto the plane
	if self.options['render-rays']:
		for spoke in self.spokes:
			# draw rays
			surface_tool.add_color(Color8(253,71,3))
			surface_tool.add_vertex(self.get_end() + spoke)
			surface_tool.add_color(Color8(253,71,3))
			surface_tool.add_vertex(self.get_end() + spoke + ray)
	
	# the resulting LE tube end after projection
	if self.options['render-inters'] and self.inters.size():
		var c = inter_colour_highlighted if self.is_highlighted else inter_colour
		for i in range(inters.size()-1):
			# sometimes we don't get an intersect between the ray and
			# the plane (rare - see comment above)
			if inters[i] and inters[i+1]:
				surface_tool.add_color(c)
				surface_tool.add_vertex(self.inters[i])
				surface_tool.add_color(c)
				surface_tool.add_vertex(self.inters[i+1])
			
		if inters[0] and inters[-1]:
			surface_tool.add_color(c)
			surface_tool.add_vertex(self.inters[0])
			surface_tool.add_color(c)
			surface_tool.add_vertex(self.inters[-1])
		
		## draw the LE + Profile join angle
		#var tmp = Vector3()
		#surface_tool.add_color(Color8(255,255,0))
		#surface_tool.add_vertex(self.point)
		
