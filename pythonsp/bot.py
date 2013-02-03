import sys
import struct
import random
from socket import *

glyphs = []
cmds = ['h', 'j', 'k', 'l']

# nethack sends coordinates formated as (col,row)

def reset_map(colno, rowno):
	for i in range(0, rowno):
		glyphs.append([[' ', 0] for j in range(0, colno)])


def dump_map():
	for line in glyphs:
		for glyph in line:
			sys.stdout.write('%c' % glyph[0])
		sys.stdout.write("\n")



s = socket(AF_UNIX, SOCK_STREAM)
s.connect("/tmp/mmsock")

s.sendall("\n")


posx = 0
posy = 0
data = []
random.seed()
reset_map(80, 21) # default

while 1:
	data.extend(s.recv(128))
	dlen = len(data)

	for i in range(0, dlen):
		if (data[i] == 'S'):
			continue

		elif (data[i] == 'E'):
			s.sendall(random.choice(cmds))

		elif (data[i] == 'm'):
			if (dlen - i > 2):
				c = ord(data[i+1])
				r = ord(data[i+2])
				reset_map(c, r)
				i += 2
			else:
				break

		elif (data[i] == 'g'):
			if (dlen - i > 3):
				c = ord(data[i+1])
				r = ord(data[i+2])
				g = data[i+3]
				glyphs[r][c][0] = g
				i += 3
				if (g == '@'):
					posx = c
					posy = r
					glyphs[r][c][1] += 1  # 'been there' count
			else:
				break

	# leftover
	if (i != dlen - 1):
		data = data[i:]
	else:
		data = []

	print "--------------------------------------------------------------"
	dump_map()
	print "--------------------------------------------------------------"
	print posx
	print posy

