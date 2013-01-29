#include <stdio.h>
#include "hack.h"
//#include "dlb.h" // definitions for data library

#include "middleman.h"


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


void
mm_init_nhwindows(argcp,argv)
	int* argcp;
	char** argv;
{
	real_winprocs.win_init_nhwindows(argcp,argv);
}

void
mm_player_selection()
{
	real_winprocs.win_player_selection();
}

void
mm_askname()
{
	real_winprocs.win_askname();
}

void
mm_get_nh_event()
{
	real_winprocs.win_get_nh_event();
}

void
mm_suspend_nhwindows(str)
    const char *str;
{
	real_winprocs.win_suspend_nhwindows(str);
}

void
mm_resume_nhwindows()
{
	real_winprocs.win_resume_nhwindows();
}

void
mm_exit_nhwindows(str)
    const char *str;
{
	real_winprocs.win_exit_nhwindows(str);
}

winid
mm_create_nhwindow(type)
    int type;
{
	real_winprocs.win_create_nhwindow(type);
}

void
mm_clear_nhwindow(window)
    winid window;
{
	real_winprocs.win_clear_nhwindow(window);
}

void
mm_display_nhwindow(window, blocking)
    winid window;
    boolean blocking;	/* with ttys, all windows are blocking */
{
	real_winprocs.win_display_nhwindow(window, blocking);
}

void
mm_destroy_nhwindow(window)
    winid window;
{
	real_winprocs.win_destroy_nhwindow(window);
}

void
mm_curs(window, x, y)
	winid window;
	register int x, y;
{
	real_winprocs.win_curs(window, x, y);
}

void
mm_putstr(window, attr, str)
    winid window;
    int attr;
    const char *str;
{
	real_winprocs.win_putstr(window, attr, str);
}

void
mm_display_file(fname, complain)
	const char *fname;
	boolean complain;
{
	real_winprocs.win_display_file(fname, complain);
}

void
mm_start_menu(window)
    winid window;
{
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
	real_winprocs.win_add_menu(window, glyph, identifier, ch, gch, attr, str,
			preselected);
}

void
mm_end_menu(window, prompt)
    winid window;	/* menu to use */
    const char *prompt;	/* prompt to for menu */
{
	real_winprocs.win_end_menu(window, prompt);
}

int
mm_select_menu(window, how, menu_list)
    winid window;
    int how;
    menu_item **menu_list;
{
	return real_winprocs.win_select_menu(window, how, menu_list);
}

/* special hack for treating top line --More-- as a one item menu */
char
mm_message_menu(let, how, mesg)
	char let;
	int how;
	const char *mesg;
{
	real_winprocs.win_message_menu(let, how, mesg);
}

void
mm_update_inventory()
{
	real_winprocs.win_update_inventory();
}

void
mm_mark_synch()
{
	real_winprocs.win_mark_synch();
}

void
mm_wait_synch()
{
	real_winprocs.win_wait_synch();
}

#ifdef CLIPPING
void
mm_cliparound(x, y)
	int x, y;
{
	real_winprocs.win_cliparound(x, y);
}
#endif /* CLIPPING */

void
mm_print_glyph(window, x, y, glyph)
    winid window;
    xchar x, y;
    int glyph;
{
	real_winprocs.win_print_glyph(window, x, y, glyph);
}

void
mm_raw_print(str)
    const char *str;
{
	real_winprocs.win_raw_print(str);
}

void
mm_raw_print_bold(str)
    const char *str;
{
	real_winprocs.win_raw_print_bold(str);
}

int
mm_nhgetch()
{
	return real_winprocs.win_nhgetch();
}

void
mm_nhbell()
{
	real_winprocs.win_nhbell();
}

int
mm_doprev_message()
{
	return real_winprocs.win_doprev_message();
}

char
mm_yn_function(query,resp, def)
	const char *query,*resp;
	char def;
{
	return real_winprocs.win_yn_function(query, resp, def);
}

void
mm_getlin(query, bufp)
	const char *query;
	register char *bufp;
{
	real_winprocs.win_getlin(query, bufp);
}

int
mm_get_ext_cmd()
{
	return real_winprocs.win_get_ext_cmd();
}

void
mm_number_pad(state)
	int state;
{
	real_winprocs.win_number_pad(state);
}

void
mm_delay_output()
{
	real_winprocs.win_delay_output();
}

int
mm_nh_poskey(x, y, mod)
    int *x, *y, *mod;
{
	return real_winprocs.win_nh_poskey(x, y, mod);
}

#ifdef POSITIONBAR
void
mm_update_positionbar(posbar)
	char *posbar;
{
	real_winprocs.win_update_positionbar(posbar);
}
#endif

void
mm_start_screen()
{
	real_winprocs.win_start_screen();
}

void
mm_end_screen()
{
	real_winprocs.win_end_screen();
}
