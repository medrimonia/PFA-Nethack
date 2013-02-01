import sys
import struct
import random
import numpy as np
from socket import *

glyphs = []
cmds = ['h', 'j', 'k', 'l']

# nethack sends coordinates formated as (col,row)

def reset_map(colno, rowno):
	for i in range(0, rowno):
		glyphs.append([' ' for j in range(0, colno)])


def dump_map():
	for line in glyphs:
		for glyph in line:
			sys.stdout.write('%c' % glyph)
		sys.stdout.write("\n")


reset_map(80, 21)
dump_map()

random.seed()

s = socket(AF_UNIX, SOCK_STREAM)
s.connect("/tmp/mmsock")

s.sendall("\n")


info = []

while 1:
	data = s.recv(128)
	info.extend(data)
	dlen = len(info)

	for i in range(0, dlen):
		if (info[i] == 'g'):
			if (dlen - i > 3):
				c = ord(info[i+1])
				l = ord(info[i+2])
				g = info[i+3]
				glyphs[l][c] = g
				i += 3
			else:
				break

	if (i != dlen - 1):
		print "leftover"
		info = info[i:]
	else:
		info = []

	dump_map()

	s.sendall(random.choice(cmds))


