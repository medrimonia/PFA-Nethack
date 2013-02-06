import sys

# nethack sends coordinates formated as (col,row)

def reset_map(glyphs, colno, rowno):
	for i in range(0, rowno):
		glyphs.append([[' ', 0] for j in range(0, colno)])


def is_valid_pos(glyphs, c, r):
	map_height = len(glyphs)
	map_width  = len(glyphs[0])

	if (c >= map_width or c < 0):
		return False;

	if (r >= map_height or r < 0):
		return False;

	g = glyphs[r][c][0]
	for i in ['.', '#', '<', '>', '$']:
		if (g == i):
			return True

	return False


def dump_map(glyphs):
	for line in glyphs:
		for glyph in line:
			sys.stdout.write('%c' % glyph[0])
		sys.stdout.write("\n")

