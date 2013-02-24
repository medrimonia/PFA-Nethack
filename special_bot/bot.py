import time
import struct
import random
from socket import *

from nhmap import *

posc = 0
posr = 0

keys = [['k', 0, -1], ['l', 1, 0], ['j', 0, 1], ['h', -1, 0]]
pos = 0
search_nb = 1          #number of searches on each case

print "new game..."

s = socket(AF_UNIX, SOCK_STREAM)
if (len(sys.argv) < 2):
	s.connect("/tmp/mmsock")
else:
	s.connect(sys.argv[1])

data = []
random.seed()
cmds = []

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
			if len(cmds) == 0:
				cmds = ["s" for j in range(0, search_nb)]

				if (is_valid_pos(glyphs, posc+keys[pos][1], posr+keys[pos][2]) == 0):
					pos = (pos + 1) % 4
				cmds.append(keys[pos][0])

			cmd = cmds[0]
			cmds = cmds[1:]
			s.sendall(cmd)
			#print cmds
			#print cmd
			#dump_map(glyphs)
			#dump_been_there(glyphs)
			#time.sleep(0.01)

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

