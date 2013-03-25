import time
import struct
import string
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
					if (cnt < mmin or mmin == -1):
						mmin = cnt
						cmds = ["s"]
					g, code = get_glyph(glyphs, c, r)
					if (code == 2359 or code == 2360):
						# kick door instead of opening : more effective :D
						cmds.append("\4" + keys[r-(posr-1)][c-(posc-1)])
					else:
						cmds.append(keys[r-(posr-1)][c-(posc-1)])
	
	return cmds


print "new game..."

s = socket(AF_UNIX, SOCK_STREAM)
if (len(sys.argv) < 2):
	s.connect("/tmp/mmsock")
else:
	s.connect(sys.argv[1])

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
			#print cmds
			#print cmd
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
				set_glyph(glyphs, c, r, g, code)
				i += 6
				if (g == '@' and code < 400):
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

