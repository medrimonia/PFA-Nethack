329, '@'      "" /* player */
330, '@'      "" /* player */
331, '@'      "" /* player */
332, '@'      "" /* player */
333, '@'      "" /* player */
334, '@'      "" /* player */
335, '@'      "" /* player */
336, '@'      "" /* player */
337, '@'      "" /* player */
338, '@'      "" /* player */
339, '@'      "" /* player */
340, '@'      "" /* player */
341, '@'      "" /* player */
2344, ' ',    "dark part of a room",    C(NO_COLOR)},    /* stone */
2345, '|',    "wall",                   C(CLR_GRAY)},    /* vwall */
2346, '-',    "wall",                   C(CLR_GRAY)},    /* hwall */
2347, '-',    "wall",                   C(CLR_GRAY)},    /* tlcorn */
2348, '-',    "wall",                   C(CLR_GRAY)},    /* trcorn */
2349, '-',    "wall",                   C(CLR_GRAY)},    /* blcorn */
2350, '-',    "wall",                   C(CLR_GRAY)},    /* brcorn */
2351, '-',    "wall",                   C(CLR_GRAY)},    /* crwall */
2352, '-',    "wall",                   C(CLR_GRAY)},    /* tuwall */
2353, '-',    "wall",                   C(CLR_GRAY)},    /* tdwall */
2354, '|',    "wall",                   C(CLR_GRAY)},    /* tlwall */
2355, '|',    "wall",                   C(CLR_GRAY)},    /* trwall */
2356, '.',    "doorway",                C(CLR_GRAY)},    /* ndoor */
2357, '-',    "open door",              C(CLR_BROWN)},    /* vodoor */
2358, '|',    "open door",              C(CLR_BROWN)},    /* hodoor */
2359, '+',    "closed door",            C(CLR_BROWN)},    /* vcdoor */
2360, '+',    "closed door",            C(CLR_BROWN)},    /* hcdoor */
2361, '#',    "iron bars",              C(HI_METAL)},    /* bars */
2362, '#',    "tree",                   C(CLR_GREEN)},    /* tree */
2363, '.',    "floor of a room",        C(CLR_GRAY)},    /* room */
2364, '#',    "corridor",               C(CLR_GRAY)},    /* dark corr */
2365, '#',    "lit corridor",           C(CLR_GRAY)},    /* lit corr (see mapglyph.c) */
2366, '<',    "staircase up",           C(CLR_GRAY)},    /* upstair */
2367, '>',    "staircase down",         C(CLR_GRAY)},    /* dnstair */
2368, '<',    "ladder up",              C(CLR_BROWN)},    /* upladder */
2369, '>',    "ladder down",            C(CLR_BROWN)},    /* dnladder */
2370, '_',    "altar",                  C(CLR_GRAY)},    /* altar */
2371, '|',    "grave",                  C(CLR_GRAY)},   /* grave */
2372, '\\',    "opulent throne",        C(HI_GOLD)},    /* throne */
2373, '#',    "sink",                   C(CLR_GRAY)},    /* sink */
2374, '{',    "fountain",               C(CLR_BLUE)},    /* fountain */
2375, '}',    "water",                  C(CLR_BLUE)},    /* pool */
2376, '.',    "ice",                    C(CLR_CYAN)},    /* ice */
2377, '}',    "molten lava",            C(CLR_RED)},    /* lava */
2378, '.',    "lowered drawbridge",     C(CLR_BROWN)},    /* vodbridge */
2379, '.',    "lowered drawbridge",     C(CLR_BROWN)},    /* hodbridge */
2380, '#',    "raised drawbridge",      C(CLR_BROWN)},/* vcdbridge */
2381, '#',    "raised drawbridge",      C(CLR_BROWN)},/* hcdbridge */
2382, ' ',    "air",                    C(CLR_CYAN)},    /* open air */
2383, '#',    "cloud",                  C(CLR_GRAY)},    /* [part of] a cloud */
2384, '}',    "water",                  C(CLR_BLUE)},    /* under water */
2385, '^',    "arrow trap",             C(HI_METAL)},    /* trap */
2386, '^',    "dart trap",              C(HI_METAL)},    /* trap */
2387, '^',    "falling rock trap",      C(CLR_GRAY)},    /* trap */
2388, '^',    "squeaky board",          C(CLR_BROWN)},    /* trap */
2389, '^',    "bear trap",              C(HI_METAL)},    /* trap */
2390, '^',    "land mine",              C(CLR_RED)},    /* trap */
2391, '^',    "rolling boulder trap",   C(CLR_GRAY)},    /* trap */
2392, '^',    "sleeping gas trap",      C(HI_ZAP)},    /* trap */
2393, '^',    "rust trap",              C(CLR_BLUE)},    /* trap */
2394, '^',    "fire trap",              C(CLR_ORANGE)},    /* trap */
2395, '^',    "pit",                    C(CLR_BLACK)},    /* trap */
2396, '^',    "spiked pit",             C(CLR_BLACK)},    /* trap */
2397, '^',    "hole",                   C(CLR_BROWN)},    /* trap */
2398, '^',    "trap door",              C(CLR_BROWN)},    /* trap */
2399, '^',    "teleportation trap",     C(CLR_MAGENTA)},    /* trap */
2400, '^',    "level teleporter",       C(CLR_MAGENTA)},    /* trap */
2401, '^',    "magic portal",           C(CLR_BRIGHT_MAGENTA)},    /* trap */
2402, '"',    "web",                    C(CLR_GRAY)},    /* web */
2403, '^',    "statue trap",            C(CLR_GRAY)},    /* trap */
2404, '^',    "magic trap",             C(HI_ZAP)},    /* trap */
2405, '^',    "anti-magic field",       C(HI_ZAP)},    /* trap */
2406, '^',    "polymorph trap",         C(CLR_BRIGHT_GREEN)},    /* trap */
2407, '|',    "wall",                   C(CLR_GRAY)},    /* vbeam */
2408, '-',    "wall",                   C(CLR_GRAY)},    /* hbeam */
2409, '\\',    "wall",                  C(CLR_GRAY)},    /* lslant */
2410, '/',    "wall",                   C(CLR_GRAY)},    /* rslant */
2411, '*',    "",                       C(CLR_WHITE)},    /* dig beam */
2412, '!',    "",                       C(CLR_WHITE)},    /* camera flash beam */
2413, ')',    "",                       C(HI_WOOD)},    /* boomerang open left */
2414, '(',    "",                       C(HI_WOOD)},    /* boomerang open right */
2415, '0',    "",                       C(HI_ZAP)},    /* 4 magic shield symbols */
2416, '#',    "",                       C(HI_ZAP)},
2417, '@',    "",                       C(HI_ZAP)},
2418, '*',    "",                       C(HI_ZAP)},
2419, '/',    "",                       C(CLR_GREEN)},    /* swallow top left    */
2420, '-',    "",                       C(CLR_GREEN)},    /* swallow top center    */
2421, '\\',    "",                      C(CLR_GREEN)},    /* swallow top right    */
2422, '|',    "",                       C(CLR_GREEN)},    /* swallow middle left    */
2423, '|',    "",                       C(CLR_GREEN)},    /* swallow middle right    */
2424, '\\',    "",                      C(CLR_GREEN)},    /* swallow bottom left    */
2425, '-',    "",                       C(CLR_GREEN)},    /* swallow bottom center*/
2426, '/',    "",                       C(CLR_GREEN)},    /* swallow bottom right    */
2427, '/',    "",                       C(CLR_ORANGE)},    /* explosion top left     */
2428, '-',    "",                       C(CLR_ORANGE)},    /* explosion top center   */
2429, '\\',    "",                      C(CLR_ORANGE)},    /* explosion top right    */
2430, '|',    "",                       C(CLR_ORANGE)},    /* explosion middle left  */
2431, ' ',    "",                       C(CLR_ORANGE)},    /* explosion middle center*/
2432, '|',    "",                       C(CLR_ORANGE)},    /* explosion middle right */
2433, '\\',    "",                      C(CLR_ORANGE)},    /* explosion bottom left  */
2434, '-',    "",                       C(CLR_ORANGE)},    /* explosion bottom center*/
2435, '/',    "",                       C(CLR_ORANGE)},    /* explosion bottom right */
