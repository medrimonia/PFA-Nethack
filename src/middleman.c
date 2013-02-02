#include "middleman.h"

#include "global.h" // nethack's globals (map size etc)

#include <stdio.h>
#include <errno.h>
#include <stdarg.h>
#include <sys/un.h>
#include <sys/socket.h>

#define BUFSIZE  64
#define SOCKPATH "/tmp/mmsock"

struct window_procs real_winprocs;

struct window_procs middleman = {
	"middleman",
	0,
	0,
    mm_init_nhwindows,
    mm_player_selection,
    mm_askname,
    mm_get_nh_event,
    mm_exit_nhwindows,
    mm_suspend_nhwindows,
    mm_resume_nhwindows,
    mm_create_nhwindow,
    mm_clear_nhwindow,
    mm_display_nhwindow,
    mm_destroy_nhwindow,
    mm_curs,
    mm_putstr,
    mm_display_file,
    mm_start_menu,
    mm_add_menu,
    mm_end_menu,
    mm_select_menu,
    mm_message_menu,
    mm_update_inventory,
    mm_mark_synch,
    mm_wait_synch,
#ifdef CLIPPING
    mm_cliparound,
#endif
#ifdef POSITIONBAR
    mm_update_positionbar,
#endif
    mm_print_glyph,
    mm_raw_print,
    mm_raw_print_bold,
    mm_nhgetch,
    mm_nh_poskey,
    mm_nhbell,
    mm_doprev_message,
    mm_yn_function,
    mm_getlin,
    mm_get_ext_cmd,
    mm_number_pad,
    mm_delay_output,
#ifdef CHANGE_COLOR	/* the Mac uses a palette device */
    mm_change_color,
#ifdef MAC
    mm_change_background,
    set_mm_font_name,
#endif
    mm_get_color_string,
#endif

    /* other defs that really should go away (they're tty specific) */
    mm_start_screen,
    mm_end_screen,
    genl_outrip,
#if defined(WIN32CON)
    ntmm_preference_update,
#else
    genl_preference_update,
#endif
};


static winid winmapid;

static FILE *log = NULL;

static int mmsock = -1;
static int client = -1;
static struct sockaddr_un local;


void mm_vlog(const char *format, ...)
{
	va_list va;

	va_start(va, format);
	if (log != NULL) {
		vfprintf(log, format, va);
		fprintf(log, "\n");
		fflush(log);
	}
	va_end(va);
}


void mm_log(const char *func, const char *msg)
{
	mm_vlog("%s: %s", func, msg);
}


void mm_cleanup()
{
	if (log != NULL) {
		fflush(log);
		fclose(log);
		log = NULL;
	}

	if (mmsock != -1) {
		close(mmsock);
		mmsock = -1;
	}

	if (client != -1) {
		close(mmsock);
		client = -1;
	}

	unlink(SOCKPATH);
}


void mm_init()
{
	int rv;
	socklen_t len;

	/* unlink SOCKPATH in case the came wasn't terminated cleanly */
	if (EBUSY == unlink(SOCKPATH)) {
		fprintf(
			stderr,
			"%s is busy, is another middleman running?\n",
			SOCKPATH
		);
		terminate(EXIT_FAILURE);
	}

	/* open log file */
	log = fopen("mm.log", "a");

	if (log == NULL) {
		perror("fopen");
	}

	/* open unix socket */
	local.sun_family = AF_UNIX;
	strcpy(local.sun_path, SOCKPATH);
	len = strlen(SOCKPATH) + sizeof local.sun_family;

	mmsock = socket(AF_UNIX, SOCK_STREAM, 0);

	if (mmsock == -1) {
		perror("socket");
		mm_log("socket()", "Could not open middleman socket.");
		terminate(EXIT_FAILURE);
	}

	if (-1 == bind(mmsock, (struct sockaddr *) &local, len)) {
		perror("bind");
		mm_vlog("bind(): Could not bind %s to middleman socket.", SOCKPATH);
		terminate(EXIT_FAILURE);
		return;
	}

	if (-1 == listen(mmsock, 1)) {
		perror("listen");
		mm_log("listen()",
		       "Could not listen for connections on mmiddleman socket.");
		terminate(EXIT_FAILURE);
		return;
	}

	// loop until a client is connected
	ssize_t size;
	char buf[BUFSIZE];
	puts("Waiting for a bot to connect...");
	while (client == -1) {
		client = accept(mmsock, NULL, NULL);
		if (client == -1) {
			perror("accept");
			mm_log("accept", "error");
		} else {
			// COLNO and ROWNO are from nethack's global.h
			sprintf(buf, "Sm%c%c", COLNO, ROWNO);
			mm_log("send()", buf);
			size = send(client, buf, strlen(buf), 0);
			if (size < 1) {
				perror("send");
				close(client);
				client = -1;
			}
		}
	}
}

#define MAX_MOVES 20000

void mm_send_update()
{
	if (moves >= MAX_MOVES){
		terminate(EXIT_SUCCESS);
	}
}


void
mm_init_nhwindows(argcp,argv)
	int* argcp;
	char** argv;
{
	mm_log("mm_init_nhwindows", "");
	real_winprocs.win_init_nhwindows(argcp,argv);
}

void
mm_player_selection()
{
	mm_log("mm_player_selection", "");
	real_winprocs.win_player_selection();
}

void
mm_askname()
{
	mm_log("mm_askname", "");
	real_winprocs.win_askname();
}

void
mm_get_nh_event()
{
	mm_log("mm_get_nh_event", "");
	real_winprocs.win_get_nh_event();
}

void
mm_suspend_nhwindows(str)
    const char *str;
{
	mm_log("mm_suspend_nhwindows", str);
	real_winprocs.win_suspend_nhwindows(str);
}

void
mm_resume_nhwindows()
{
	mm_log("mm_resume_nhwindows", "");
	real_winprocs.win_resume_nhwindows();
}

void
mm_exit_nhwindows(str)
    const char *str;
{
	mm_log("mm_exit_nhwindows", str);
	real_winprocs.win_exit_nhwindows(str);
}

winid
mm_create_nhwindow(type)
    int type;
{
	mm_vlog("mm_create_nhwindow: type %d", type);
	winid id = real_winprocs.win_create_nhwindow(type);

	if (type == NHW_MAP) {
		winmapid = id;
	}

	return id;
}

void
mm_clear_nhwindow(window)
    winid window;
{
	mm_vlog("mm_clear_nhwindow: %d", window);
	if (window == winmapid) {
		// only show the map for now
		real_winprocs.win_clear_nhwindow(window);
	}
}

void
mm_display_nhwindow(window, blocking)
    winid window;
    boolean blocking;
{
	mm_vlog("mm_display_nhwindow: %d", window);

	if (window == winmapid) {
		// only show the map for now
		real_winprocs.win_display_nhwindow(window, 0); // non-blocking
	}
}

void
mm_destroy_nhwindow(window)
    winid window;
{
	mm_log("mm_destroy_nhwindow", "");
	real_winprocs.win_destroy_nhwindow(window);
}

void
mm_curs(window, x, y)
	winid window;
	register int x, y;
{
	mm_log("mm_curs", "");
	real_winprocs.win_curs(window, x, y);
}

void
mm_putstr(window, attr, str)
    winid window;
    int attr;
    const char *str;
{
	mm_log("mm_putstr", str);
	//real_winprocs.win_putstr(window, attr, str);
}

void
mm_display_file(fname, complain)
	const char *fname;
	boolean complain;
{
	mm_log("mm_display_file", fname);
	real_winprocs.win_display_file(fname, complain);
}

void
mm_start_menu(window)
    winid window;
{
	mm_log("mm_start_menu", "");
	real_winprocs.win_start_menu(window);
}

void
mm_add_menu(window, glyph, identifier, ch, gch, attr, str, preselected)
    winid window;	/* window to use, must be of type NHW_MENU */
    int glyph;		/* glyph to display with item (unused) */
    const anything *identifier;	/* what to return if selected */
    char ch;		/* keyboard accelerator (0 = pick our own) */
    char gch;		/* group accelerator (0 = no group) */
    int attr;		/* attribute for string (like mm_putstr()) */
    const char *str;	/* menu string */
    boolean preselected; /* item is marked as selected */
{
	mm_log("mm_add_menu", str);
	//real_winprocs.win_add_menu(window, glyph, identifier, ch, gch, attr, str,
	//		preselected);
}

void
mm_end_menu(window, prompt)
    winid window;	/* menu to use */
    const char *prompt;	/* prompt to for menu */
{
	mm_log("mm_end_menu", prompt);
	//real_winprocs.win_end_menu(window, prompt);
}

int
mm_select_menu(window, how, menu_list)
    winid window;
    int how;
    menu_item **menu_list;
{
	mm_log("mm_select_menu", "");
	return real_winprocs.win_select_menu(window, how, menu_list);
}

/* special hack for treating top line --More-- as a one item menu */
char
mm_message_menu(let, how, mesg)
	char let;
	int how;
	const char *mesg;
{
	mm_log("mm_message_menu", mesg);
	real_winprocs.win_message_menu(let, how, mesg);
}

void
mm_update_inventory()
{
	mm_log("mm_update_inventory", "");
	real_winprocs.win_update_inventory();
}

void
mm_mark_synch()
{
	mm_log("mm_mark_synch", "");
	real_winprocs.win_mark_synch();
}

void
mm_wait_synch()
{
	mm_log("mm_wait_synch", "");
	real_winprocs.win_wait_synch();
}

#ifdef CLIPPING
void
mm_cliparound(x, y)
	int x, y;
{
	mm_log("mm_cliparound", "");
	real_winprocs.win_cliparound(x, y);
}
#endif /* CLIPPING */

void
mm_print_glyph(window, x, y, glyph)
    winid window;
    xchar x, y;
    int glyph;
{
	int ochar, ocolor;
	unsigned ospecial;

	char buf[BUFSIZE];
	ssize_t size;

	mapglyph(glyph, &ochar, &ocolor, &ospecial, x, y);
	mm_vlog("mm_print_glyph: window %d - %d:%d:%c", window, x, y, ochar);

	if (client != -1) {
		size = sprintf(buf, "g%c%c%c", x, y, ochar);
		mm_log("send()", buf);
		send(client, buf, size, 0);
	}

	real_winprocs.win_print_glyph(window, x, y, glyph);
}

void
mm_raw_print(str)
    const char *str;
{
	mm_log("mm_raw_print", str);
	//real_winprocs.win_raw_print(str);
}

void
mm_raw_print_bold(str)
    const char *str;
{
	mm_log("mm_raw_print_bold", str);
	real_winprocs.win_raw_print_bold(str);
}

int
mm_nhgetch()
{
	mm_log("mm_nhgetch", "");
	return real_winprocs.win_nhgetch();
}

void
mm_nhbell()
{
	mm_log("mm_nhbell", "");
	real_winprocs.win_nhbell();
}

int
mm_doprev_message()
{
	mm_log("mm_doprev_message", "");
	return real_winprocs.win_doprev_message();
}

char
mm_yn_function(query,resp, def)
	const char *query,*resp;
	char def;
{
	mm_log("mm_yn_function", query);
	return real_winprocs.win_yn_function(query, resp, def);
}

void
mm_getlin(query, bufp)
	const char *query;
	register char *bufp;
{
	mm_log("mm_getlin", query);
	real_winprocs.win_getlin(query, bufp);
}

int
mm_get_ext_cmd()
{
	mm_log("mm_get_ext_cmd", "");
	return real_winprocs.win_get_ext_cmd();
}

void
mm_number_pad(state)
	int state;
{
	mm_log("mm_number_pad", "");
	real_winprocs.win_number_pad(state);
}

void
mm_delay_output()
{
	mm_log("mm_delay_output", "");
	real_winprocs.win_delay_output();
}

/* This function returns a key or 0 if a mouse button was used.
 * x and y are used with interfaces suporting the mouse. */
int
mm_nh_poskey(x, y, mod)
    int *x, *y, *mod;
{
	int i, cmd, nb_received;
	ssize_t size;
	char buf[BUFSIZE];

	static int cmdbuf[BUFSIZE];
	static unsigned int first = 0;
	static unsigned int last = 0;

	mm_log("mm_nh_poskey", "");

	if (first == last) { // buffer empty
		
		first = 0;
		last = 0;

		mm_log("send()", "E");
		size = send(client, "E", 1, 0);
		if (size < 1) {
			mm_log("send()", "Client disconnected.");
			terminate(EXIT_FAILURE);
		}

		nb_received = recv(client, buf, BUFSIZE, 0);
		if (nb_received < 1) {
			mm_log("recv()", "Client disconnected.");
			terminate(EXIT_FAILURE);
		} else {
			mm_log("recv()", buf);
		}

		mm_log("send()", "S");
		size = send(client, "S", 1, 0);
		if (size < 1) {
			mm_log("send()", "Client disconnected.");
			terminate(EXIT_FAILURE);
		} else {
			// put extra chars in a buffer
			for (i = 1; i < nb_received; i++) {
				cmdbuf[++last % BUFSIZE] = buf[i];
			}

			cmd = buf[0];
		}
	}
	
	else {
		cmd = cmdbuf[++first % BUFSIZE];
	}
	
	return cmd;

	//return real_winprocs.win_nh_poskey(x, y, mod);
}

#ifdef POSITIONBAR
void
mm_update_positionbar(posbar)
	char *posbar;
{
	mm_log("mm_update_positionbar", "");
	real_winprocs.win_update_positionbar(posbar);
}
#endif

void
mm_start_screen()
{
	mm_log("mm_start_screen", "");
	real_winprocs.win_start_screen();
}

void
mm_end_screen()
{
	mm_log("mm_end_screen", "");
	real_winprocs.win_end_screen();
}
