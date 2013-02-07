import sys

# nethack sends coordinates formated as (col,row)

def new_map(colno, rowno):
	glyphs = []
	for i in range(0, rowno):
		glyphs.append([[' ', 0] for j in range(0, colno)])

	return glyphs


def is_valid_pos(glyphs, c, r):
	map_height = len(glyphs)
	map_width  = len(glyphs[0])

	if (c >= map_width or c < 0):
		return False;

	if (r >= map_height or r < 0):
		return False;

	g = glyphs[r][c][0]
	for i in ['.', '#', '<', '>', '$', '+']:
		if (g == i):
			return True

	return False

def get_glyph(glyphs, c, r):
	return glyphs[r][c][0]

def set_glyph(glyphs, c, r, g):
	glyphs[r][c][0] = g

def been_there_count(glyphs, c, r):
	return glyphs[r][c][1]

def been_there_inc(glyphs, c, r):
	glyphs[r][c][1] += 1

def dump_map(glyphs):
	for line in glyphs:
		for glyph in line:
			sys.stdout.write('%c' % glyph[0])
		sys.stdout.write("\n")

def dump_been_there(glyphs):
	for line in glyphs:
		for glyph in line:
			sys.stdout.write('%i' % glyph[1])
		sys.stdout.write("\n")
