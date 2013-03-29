import time
import struct
import string
import random
from socket import *

from nhmap import *

posc = 0
posr = 0

map_width = 80; # default
map_height = 21; # default
glyphs = new_map(map_width, map_height)

keys = [['k', 0, -1], ['l', 1, 0], ['j', 0, 1], ['h', -1, 0]]
pos = 0
search_nb = 3          #number of searches on each tile
search_step = 2        #lunch searches every 2 tiles


s = socket(AF_UNIX, SOCK_STREAM)
if (len(sys.argv) < 2):
	s.connect("/tmp/mmsock")
else:
	s.connect(sys.argv[1])

data = []
random.seed()
cmds = []
tile_index = 0

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

		elif (data[i] == 'C'):
			i += 1;
			glyphs = new_map(map_width, map_height)
			continue

		elif (data[i] == 'E'):
			i += 1
			if len(cmds) == 0:
				if tile_index == 0:
					cmds = ["s" for j in range(0, search_nb)]
				tile_index = (tile_index + 1) % search_step

				if (is_valid_pos(glyphs, posc+keys[pos][1], posr+keys[pos][2]) == 0):
					pos = (pos + 1) % 4
				cmds.append(keys[pos][0])

			cmd = cmds[0]
			cmds = cmds[1:]
			s.sendall(cmd)
			#dump_map(glyphs)
			#dump_been_there(glyphs)
			#time.sleep(0.05)

		elif (data[i] == 'm'):
			if (dlen - i > 2):
				map_width = ord(data[i+1])
				map_height = ord(data[i+2])
				glyphs = new_map(map_width, map_height)
				i += 3
			else:
				break

		elif (data[i] == 'g'):
			if (dlen - i > 5):
				c = ord(data[i+1])
				r = ord(data[i+2])
				g = data[i+3]
				code = struct.unpack('H', ''.join(data[i+4:i+6]))[0]
				i += 6
				if (g == '@' and code < 400):
					posc = c
					posr = r
				elif (g != '@'):
					set_glyph(glyphs, c, r, g, code)
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

