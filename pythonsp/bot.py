import struct
import random
from socket import *

from nhmap import *

posc = 0
posr = 0
glyphs = []

keys = [['y', 'k', 'u'],
        ['h', ' ', 'l'],
        ['b', 'j', 'n']]


def build_cmd_list():
	cmds = []

	for c in range(posc - 1, posc + 2):
		for r in range(posr - 1, posr + 2):
			if (c == posc and r == posr):
				continue
			if (is_valid_pos(glyphs, c, r)):
				cmds.append(keys[r-(posr-1)][c-(posc-1)])
	
	return cmds




s = socket(AF_UNIX, SOCK_STREAM)
s.connect("/tmp/mmsock")

s.sendall("\n")


data = []
random.seed()


map_width = 80; # default
map_height = 21; # default
reset_map(glyphs, map_width, map_height)

while 1:
	
	data.extend(s.recv(128))
	dlen = len(data)

	for i in range(0, dlen):
		if (data[i] == 'S'):
			continue

		elif (data[i] == 'E'):
			cmds = build_cmd_list()
			if (len(cmds) == 0):
				cmds = ['\n']
			print cmds
			s.sendall(random.choice(cmds))

		elif (data[i] == 'm'):
			if (dlen - i > 2):
				map_width = ord(data[i+1])
				map_height = ord(data[i+2])
				reset_map(glyphs, map_width, map_height)
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
					posc = c
					posr = r
					glyphs[r][c][1] += 1  # 'been there' count
			else:
				break

	# leftover
	if (i != dlen - 1):
		data = data[i:]
	else:
		data = []


	print "--------------------------------------------------------------"
	dump_map(glyphs)
	print "--------------------------------------------------------------"

