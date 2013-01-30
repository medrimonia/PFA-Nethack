#ifndef MIDDLEMAN_H
#define MIDDLEMAN_H

#include "hack.h"

#include "wintype.h"
#include "winprocs.h"


extern struct window_procs middleman;
extern struct window_procs real_winprocs;


void FDECL(mm_init_nhwindows, (int *, char **));
void NDECL(mm_player_selection);
void NDECL(mm_askname);
void NDECL(mm_get_nh_event) ;
void FDECL(mm_exit_nhwindows, (const char *));
void FDECL(mm_suspend_nhwindows, (const char *));
void NDECL(mm_resume_nhwindows);
winid FDECL(mm_create_nhwindow, (int));
void FDECL(mm_clear_nhwindow, (winid));
void FDECL(mm_display_nhwindow, (winid, BOOLEAN_P));
void FDECL(mm_dismiss_nhwindow, (winid));
void FDECL(mm_destroy_nhwindow, (winid));
void FDECL(mm_curs, (winid,int,int));
void FDECL(mm_putstr, (winid, int, const char *));
void FDECL(mm_display_file, (const char *, BOOLEAN_P));
void FDECL(mm_start_menu, (winid));
void FDECL(mm_add_menu, (winid,int,const ANY_P *,
			CHAR_P,CHAR_P,int,const char *, BOOLEAN_P));
void FDECL(mm_end_menu, (winid, const char *));
int FDECL(mm_select_menu, (winid, int, MENU_ITEM_P **));
char FDECL(mm_message_menu, (CHAR_P,int,const char *));
void NDECL(mm_update_inventory);
void NDECL(mm_mark_synch);
void NDECL(mm_wait_synch);
#ifdef CLIPPING
void FDECL(mm_cliparound, (int, int));
#endif
#ifdef POSITIONBAR
void FDECL(mm_update_positionbar, (char *));
#endif
void FDECL(mm_print_glyph, (winid,XCHAR_P,XCHAR_P,int));
void FDECL(mm_raw_print, (const char *));
void FDECL(mm_raw_print_bold, (const char *));
int NDECL(mm_nhgetch);
int FDECL(mm_nh_poskey, (int *, int *, int *));
void NDECL(mm_nhbell);
int NDECL(mm_doprev_message);
char FDECL(mm_yn_function, (const char *, const char *, CHAR_P));
void FDECL(mm_getlin, (const char *,char *));
int NDECL(mm_get_ext_cmd);
void FDECL(mm_number_pad, (int));
void NDECL(mm_delay_output);
#ifdef CHANGE_COLOR
void FDECL(mm_change_color,(int color,long rgb,int reverse));
#ifdef MAC
void FDECL(mm_change_background,(int white_or_black));
short FDECL(set_mm_font_name, (winid, char *));
#endif
char * NDECL(mm_get_color_string);
#endif

/* other defs that really should go away (they're tty specific) */
void NDECL(mm_start_screen);
void NDECL(mm_end_screen);

#endif	/* MIDDLEMAN_H */
