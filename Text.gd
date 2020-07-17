extends Node

# http://paulbourke.net/dataformats/hershey/

func str_horizontal(text, scale, offset):
	var coords = Text.strr(text, scale, offset)
	# HACK ALERT - swap Y with Z to rotate
	for i in range(coords.size()):
		coords[i][0].z = -coords[i][0].y
		coords[i][0].y = 0
		
		coords[i][1].z = -coords[i][1].y
		coords[i][1].y = 0
		
	return coords
	
func strr(text, scale, offset):
	var coords = []
	for letter in text:
		match letter:
			" " :
				offset += letter_I.new().get_width() * scale
			"A" :
				coords += letter_A.new().draw(scale, offset)
				offset += letter_A.new().get_width() * scale
			"B" :
				coords += letter_B.new().draw(scale, offset)
				offset += letter_B.new().get_width() * scale
			"C" :
				coords += letter_C.new().draw(scale, offset)
				offset += letter_C.new().get_width() * scale
			"D" :
				coords += letter_D.new().draw(scale, offset)
				offset += letter_D.new().get_width() * scale
			"E" :
				coords += letter_E.new().draw(scale, offset)
				offset += letter_E.new().get_width() * scale
			"F" :
				coords += letter_F.new().draw(scale, offset)
				offset += letter_F.new().get_width() * scale
			"G" :
				coords += letter_G.new().draw(scale, offset)
				offset += letter_G.new().get_width() * scale
			"H" :
				coords += letter_H.new().draw(scale, offset)
				offset += letter_H.new().get_width() * scale
			"I" :
				coords += letter_I.new().draw(scale, offset)
				offset += letter_I.new().get_width() * scale
			"J" :
				coords += letter_J.new().draw(scale, offset)
				offset += letter_J.new().get_width() * scale
			"K" :
				coords += letter_K.new().draw(scale, offset)
				offset += letter_K.new().get_width() * scale
			"L" :
				coords += letter_L.new().draw(scale, offset)
				offset += letter_L.new().get_width() * scale
			"M" :
				coords += letter_M.new().draw(scale, offset)
				offset += letter_M.new().get_width() * scale
			"N" :
				coords += letter_N.new().draw(scale, offset)
				offset += letter_N.new().get_width() * scale
			"O" :
				coords += letter_O.new().draw(scale, offset)
				offset += letter_O.new().get_width() * scale
			"P" :
				coords += letter_P.new().draw(scale, offset)
				offset += letter_P.new().get_width() * scale
			"Q" :
				coords += letter_Q.new().draw(scale, offset)
				offset += letter_Q.new().get_width() * scale
			"R" :
				coords += letter_R.new().draw(scale, offset)
				offset += letter_R.new().get_width() * scale
			"S" :
				coords += letter_S.new().draw(scale, offset)
				offset += letter_S.new().get_width() * scale
			"T" :
				coords += letter_T.new().draw(scale, offset)
				offset += letter_T.new().get_width() * scale
			"U" :
				coords += letter_U.new().draw(scale, offset)
				offset += letter_U.new().get_width() * scale
			"V" :
				coords += letter_V.new().draw(scale, offset)
				offset += letter_V.new().get_width() * scale
			"W" :
				coords += letter_W.new().draw(scale, offset)
				offset += letter_W.new().get_width() * scale
			"X" :
				coords += letter_X.new().draw(scale, offset)
				offset += letter_X.new().get_width() * scale
			"Y" :
				coords += letter_Y.new().draw(scale, offset)
				offset += letter_Y.new().get_width() * scale
			"0" :
				coords += letter_0.new().draw(scale, offset)
				offset += letter_0.new().get_width() * scale
			"1" :
				coords += letter_1.new().draw(scale, offset)
				offset += letter_1.new().get_width() * scale
			"2" :
				coords += letter_2.new().draw(scale, offset)
				offset += letter_2.new().get_width() * scale
			"3" :
				coords += letter_3.new().draw(scale, offset)
				offset += letter_3.new().get_width() * scale
			"4" :
				coords += letter_4.new().draw(scale, offset)
				offset += letter_4.new().get_width() * scale
			"5" :
				coords += letter_5.new().draw(scale, offset)
				offset += letter_5.new().get_width() * scale
			"6" :
				coords += letter_6.new().draw(scale, offset)
				offset += letter_6.new().get_width() * scale
			"7" :
				coords += letter_7.new().draw(scale, offset)
				offset += letter_7.new().get_width() * scale
			"8" :
				coords += letter_8.new().draw(scale, offset)
				offset += letter_8.new().get_width() * scale
			"9" :
				coords += letter_9.new().draw(scale, offset)
				offset += letter_9.new().get_width() * scale
			"!":
				coords += letter_Ex.new().draw(scale, offset)
				offset += letter_Ex.new().get_width() * scale
	return coords


class Letter:
	# co-ordinate pairs
	var coords = []
	var width = 21
	var strokes = []
	
	func _init():
		
		for stroke in get_strokes():
			var pos = 0
			for x in range(stroke.size()/2-1):
				self.coords.append([
					Vector3(stroke[pos], stroke[pos+1], 0),
					Vector3(stroke[pos+2], stroke[pos+3], 0)
				])
				pos += 2

	func draw(scale:Vector3, x:Vector3):
		var ret = []
		for p in self.coords:
			ret.append([p[0] * scale + x, p[1] * scale + x])
		return ret
	
	func get_strokes():
		return []
		
	func get_width():
		return Vector3(0.1,0,0)



# 8,10, /* Ascii 33 */ !!!!!!!
class letter_Ex extends Letter:
	func get_width():
		return Vector3(18,0,0)
	func get_strokes():
		return [
			[5,21, 5, 7],
			[5, 2, 4, 1, 5, 0, 6, 1, 5, 2]
		]

# 8,18, /* Ascii 65 */
class letter_A extends Letter:
	func get_width():
		return Vector3(18,0,0)
	func get_strokes():
		return [
			[9,21,1,0],
			[9,21,17,0],
			[4,7,14,7]
		]

# 23,21, /* Ascii 66 */
class letter_B extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[4,21, 4, 0],
			[4,21,13,21,16,20,17,19,18,17,18,15,17,13,16,12,13,11],
			[4,11,13,11,16,10,17,9,18,7,18,4,17,2,16,1,13,0,4,0]
		]

# 18,21, /* Ascii 67 */
class letter_C extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[18,16,17,18,15,20,13,21,9,21,7,20,5,18,4,16,3,13,3,8,4,5,5,3,7,
			1,9,0,13,0,15,1,17,3,18,5]
		]

# 15,21, /* Ascii 68 */
class letter_D extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,11,21,14,20,16,18,17,16,18,13,18,8,17,5,16,3,14,1,11,0,4,0]
		]

# 11,19, /* Ascii 69 */
class letter_E extends Letter:
	func get_width():
		return Vector3(19,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,17,21],
			[4,11,12,11],
			[4,0,17,0]
		]

# 8,18, /* Ascii 70 */
class letter_F extends Letter:
	func get_width():
		return Vector3(18,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,17,21],
			[4,11,12,11]
		]

# 22,21, /* Ascii 71 */
class letter_G extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[18,16,17,18,15,20,13,21,9,21,7,20,5,18,4,16,3,13,3,
			8,4,5,5,3,7,1,9,0,13,0,15,1,17,3,18,5,18,8],
			[13,8,18,8]
		]

#8,22, /* Ascii 72 */
class letter_H extends Letter:
	func get_width():
		return Vector3(22,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[18,21,18, 0],
			[4,11,18,11]
		]

#2, 8, /* Ascii 73 */
class letter_I extends Letter:
	func get_width():
		return Vector3(8,0,0)
	func get_strokes():
		return [
			[4,21,4,0]
		]

#10,16, /* Ascii 74 */
class letter_J extends Letter:
	func get_width():
		return Vector3(16,0,0)
	func get_strokes():
		return [
			[12,21,12,5,11,2,10,1,8,0,6,0,4,1,3,2,2,5,2,7]
		]

#8,21, /* Ascii 75 */
class letter_K extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[18,21,4,7],
			[9,12,18,0]
		]

#5,17, /* Ascii 76 */
class letter_L extends Letter:
	func get_width():
		return Vector3(17,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,0,16,0]
		]

#11,24, /* Ascii 77 */
class letter_M extends Letter:
	func get_width():
		return Vector3(24,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,12,0],
			[20,21,12,0],
			[20,21,20,0]
		]

#8,22, /* Ascii 78 */
class letter_N extends Letter:
	func get_width():
		return Vector3(22,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,18,0],
			[18,21,18,0]
		]

#21,22, /* Ascii 79 */
class letter_O extends Letter:
	func get_width():
		return Vector3(22,0,0)
	func get_strokes():
		return [
			[9,21,7,20,5,18,4,16,3,13,3,8,4,5,5,3,7,1,9,0,13,0,15,
			1,17,3,18,5,19,8,19,13,18,16,17,18,15,20,13,21,9,21]
		]

#13,21, /* Ascii 80 */
class letter_P extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[4,21, 4, 0],
			[4,21,13,21,16,20,17,19,18,17,18,14,17,12,16,11,13,10,4,10]
		]

#24,22, /* Ascii 81 */
class letter_Q extends Letter:
	func get_width():
		return Vector3(22,0,0)
	func get_strokes():
		return [
			[9,21,7,20,5,18,4,16,3,13,3,8,4,5,5,
			3,7,1,9,0,13,0,15,1,17,3,18,5,19,8,19,
			13,18,16,17,18,15,20,13,21,9,21],
			[12, 4,18,-2]
		]

#16,21, /* Ascii 82 */
class letter_R extends Letter:
	func get_width():
		return Vector3(21,0,0)
	func get_strokes():
		return [
			[4,21,4,0],
			[4,21,13,21,16,20,17,19,18,17,18,15,17,13,16,12,13,11,4,11],
			[11,11,18,0]
		]

#20,20, /* Ascii 83 */
class letter_S extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[17,18,15,20,12,21,8,21,5,20,3,18,3,16,4,14,
			5,13,7,12,13,10,15,
			9,16,8,17,6,17,3,15,1,12,0,8,0,5,1,3,3]
		]

#5,16, /* Ascii 84 */
class letter_T extends Letter:
	func get_width():
		return Vector3(16,0,0)
	func get_strokes():
		return [
			[8,21,8,0],
			[1,21,15,21]
		]

#10,22, /* Ascii 85 */
class letter_U extends Letter:
	func get_width():
		return Vector3(22,0,0)
	func get_strokes():
		return [
			[4,21,4,6,5,3,7,1,10,0,12,0,15,1,17,3,18,6,18,21]
		]

#5,18, /* Ascii 86 */
class letter_V extends Letter:
	func get_width():
		return Vector3(18,0,0)
	func get_strokes():
		return [
			[1,21,9,0],
			[17,21,9,0]
		]

#11,24, /* Ascii 87 */
class letter_W extends Letter:
	func get_width():
		return Vector3(24,0,0)
	func get_strokes():
		return [
			[2,21,7,0],
			[12,21,7,0],
			[12,21,17,0],
			[22,21,17,0]
		]

#5,20, /* Ascii 88 */
class letter_X extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[3,21,17,0],
			[17,21,3,0]
		]

#6,18, /* Ascii 89 */
class letter_Y extends Letter:
	func get_width():
		return Vector3(18,0,0)
	func get_strokes():
		return [
			[1,21,9,11,9,0],
			[17,21,9,11]
		]

#8,20, /* Ascii 90 */
class letter_Z extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[17,21,3,0],
			[3,21,17,21],
			[3,0,17,0]
		]


# 17,20, /* Ascii 48 */
class letter_0 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[9,21,6,20,4,17,3,12,3,9,4,4,6,1,9,0,11,0,14,1,16,
			4,17,9,17,12,16,17,14,20,11,21, 9,21]
		]

# 4,20, /* Ascii 49 */
class letter_1 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[6,17,8,18,11,21,11,0]
		]

# 14,20, /* Ascii 50 */
class letter_2 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[4,16,4,17,5,19,6,20,8,21,12,21,14,20,15,19,16,17,16,
			15,15,13,13,10,3,0,17,0]
		]

# 15,20, /* Ascii 51 */
class letter_3 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[5,21,16,21,10,13,13,13,15,12,16,11,17,8,17,6,16,
			3,14,1,11,0,8,0,5,1,4,2,3,4]
		]

# 6,20, /* Ascii 52 */
class letter_4 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[13,21,3,7,18,7],
			[13,21,13,0]
		]

# 17,20, /* Ascii 53 */
class letter_5 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[15,21,5,21,4,12,5,13,8,14,11,14,14,13,16,11,
			17,8,17,6,16,3,14,1,11,0,8,0,5,1,4,2,3,4]
		]

# 23,20, /* Ascii 54 */
class letter_6 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[16,18,15,20,12,21,10,21,7,20,5,17,4,12,4,7,
			5,3,7,1,10,0,11,0,14,1,16,3,17,6,17,7,16,
			10,14,12,11,13,10,13,7,12,5,10,4,7]
		]

# 5,20, /* Ascii 55 */
class letter_7 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[17,21,7,0],
			[3,21,17,21]
		]

# 29,20, /* Ascii 56 */
class letter_8 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[8,21,5,20,4,18,4,16,5,14,7,13,11,12,14,11,16,
			9,17,7,17,4,16,2,15,1,12,0,8,0,5,1,4,2,3,
			4,3,7,4,9,6,11,9,12,13,13,15,14,16,16,16,18,15,
			20,12,21,8,21]
		]

# 23,20, /* Ascii 57 */
class letter_9 extends Letter:
	func get_width():
		return Vector3(20,0,0)
	func get_strokes():
		return [
			[16,14,15,11,13,9,10,8,9,8,6,9,4,11,
			3,14,3,15,4,18,6,20,9,21,10,21,13,20,15,18,
			16,14,16,9,15,4,13,1,10,0,8,0,5,1,4,3]
		]
