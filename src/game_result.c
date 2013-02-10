#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "game_result.h"

#include "game_statistics.h"

struct property{
	const char * name;
	const char * value;
	bool is_text;
};

typedef struct property * property_p;

struct game_result{
	const char * mode;
	property_p * properties;
	int nb_properties;
};

typedef struct game_result * game_result_p;

property_p new_property(){
	property_p new = malloc(sizeof(struct property));
	new->name = NULL;
	new->value = NULL;
	new->is_text = false;
	return new;
}

game_result_p new_game_result(const char * mode){
	game_result_p new = malloc(sizeof(struct game_result));
	new->mode = mode;
	if (strcmp(mode, "seek_secret") == 0){
		new->nb_properties = 11;
	}
	new->properties = malloc(new->nb_properties * sizeof(property_p));
	int i;
	for (i = 0; i < new->nb_properties; i++){
		new->properties[i] = new_property();
	}
	return new;
}

/* Including game_statistics imply to include all the nethack kernel,
 * That doesn't seems to be a good idea, maybe there's something to do
 * with '#if'?
 * A solution might be to move the code of new_game_result in game_statistics,
 * but then game_statistics dependance to database_manager should be
 * facultative.
 * Best solution might be to get the initialisation code inside of the
 * middle_man
 */
game_result_p create_actual_game_result(const char * mode){
	#ifndef NETHACK_ACCESS
	make_random_stats();
	#endif
	game_result_p gr = new_game_result(mode);

#define DATABASE_FIELD(num, name, cType, sqlType)				\
  gr_set_property_name(gr, num, #name);                 \
	gr_set_property_##sqlType##_value(gr, num, get_##name () );
#include "seek_secret.def"

	return gr;
}

void destroy_game_result(game_result_p gr){
	int i;
	for (i = 0; i < gr->nb_properties; i++){
		if (gr->properties[i]->value != NULL)
			free((char *)gr->properties[i]->value);
		free(gr->properties[i]);
	}
	free(gr->properties);
	free(gr);
}


void gr_set_property_name(game_result_p gr,
													int index,
													char * name){
	gr->properties[index]->name = name;	
}

void gr_set_property_value(game_result_p gr,
													 int index,
													 const char * value,
													 bool is_text){
	if (gr->properties[index]->value != NULL)
		free((char *)gr->properties[index]->value);
	gr->properties[index]->value = value;
	gr->properties[index]->is_text = is_text;
}

void gr_set_property_text_value(game_result_p gr,
																int index,
																const char * value){
	gr_set_property_value(gr, index, strdup(value), true);
}


void gr_set_property_integer_value(game_result_p gr,
																	 int index,
																	 int value){
	int size = 0;
	int tmp = value;
	while (tmp > 0){
		tmp = tmp / 10;
		size++;
	}
	if (value < 0)
		size++;
	char * new_value = malloc(size * sizeof(char *));
	sprintf(new_value, "%d", value);
	gr_set_property_value(gr, index, new_value, false);
}

const char * gr_get_property_name(game_result_p gr,
																	int index){
	return gr->properties[index]->name;
}

const char * gr_get_property_value(game_result_p gr,
																	 int index){
	return gr->properties[index]->value;
}

bool gr_is_property_text(game_result_p gr,
																 int index){
	return gr->properties[index]->is_text;
}


const char * gr_get_mode(game_result_p gr){
	return gr->mode;
}

int gr_get_nb_properties(game_result_p gr){
	return gr->nb_properties;
}
