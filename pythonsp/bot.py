import time
import struct
import random
from socket import *

from nhmap import *

posc = 0
posr = 0

keys = [['y', 'k', 'u'],
        ['h', ' ', 'l'],
        ['b', 'j', 'n']]


def build_cmd_list():
	mmin = -1
	cmds = ["s"]

	for c in range(posc - 1, posc + 2):
		for r in range(posr - 1, posr + 2):
			if (c == posc and r == posr):
				continue
			if (is_valid_pos(glyphs, c, r)):
				cnt = been_there_count(glyphs, c, r)
				if (cnt <= mmin or mmin == -1):
					mmin = cnt
					if (cnt < mmin):
						cmds = ["s"]
					g = get_glyph(glyphs, c, r)
					if (g == '+'):
						cmds.append("o" + keys[r-(posr-1)][c-(posc-1)])
					else:
						cmds.append(keys[r-(posr-1)][c-(posc-1)])
	
	return cmds


print "new game..."


s = socket(AF_UNIX, SOCK_STREAM)
s.connect("/tmp/mmsock")

data = []
random.seed()


map_width = 80; # default
map_height = 21; # default
glyphs = new_map(map_width, map_height)

while 1:
	
	received = s.recv(128)
	data.extend(received)
	dlen = len(data)

	if (dlen == 0):
		break

	i = 0
	while (i < dlen):
		if (data[i] == 'S'):
			i += 1
			continue

		elif (data[i] == 'E'):
			i += 1
			cmds = build_cmd_list()
			cmd = random.choice(cmds)
			s.sendall(cmd)

		elif (data[i] == 'm'):
			if (dlen - i > 2):
				map_width = ord(data[i+1])
				map_height = ord(data[i+2])
				glyphs = new_map(map_width, map_height)
				i += 3
			else:
				break

		elif (data[i] == 'g'):
			if (dlen - i > 3):
				c = ord(data[i+1])
				r = ord(data[i+2])
				g = data[i+3]
				set_glyph(glyphs, c, r, g)
				i += 4
				if (g == '@'):
					posc = c
					posr = r
					been_there_inc(glyphs, c, r)  # 'been there' count
			else:
				break

		else: # unknown char
			i += 1

	# leftover
	if (i != dlen - 1):
		data = data[i:]
	else:
		data = []

s.close()

