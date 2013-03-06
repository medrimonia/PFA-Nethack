package bot;

import java.util.HashMap;

public enum SquareType {
	UNKNOWN(' '),
	EMPTY('.'),
	PASSAGE('#'),
	CLOSED_DOOR('+'),
	VERTICAL_WALL('|'),
	HORIZONTAL_WALL('-'),
	WAY_UP('<'),
	FORBIDDEN('X'),
	WAY_DOWN('>');
	
	private char token;
	private static HashMap<Character,SquareType> mySquareTypes;
	
	SquareType(char c){
		this.token = c;
	}
	
	public char getToken(){
		return token;
	}
	
	static{
		mySquareTypes = new HashMap<Character,SquareType>();
		for (SquareType t : SquareType.values()){
			mySquareTypes.put(t.token, t);
		}
	}
	
	public static SquareType tokenToVariables(char token){
		if (mySquareTypes.containsKey(token))
			return mySquareTypes.get(token);
		// Special cases which are supposed to be handled in patches later
		if (token == '$' ||
				token == '?' ||
				token == '@')
			return EMPTY;
		return UNKNOWN;
	}
	
	public boolean diagonalyPassable(){
		return (this != VERTICAL_WALL &&
				this != HORIZONTAL_WALL &&
				this != CLOSED_DOOR &&
				this != UNKNOWN);
	}
	
	public boolean openable(){
		return this == CLOSED_DOOR;
	}
	
	public boolean searchable(){
		switch (this){
		case UNKNOWN:
		case VERTICAL_WALL:
		case HORIZONTAL_WALL:
			return true;
		default: return false;
		}
	}
	
	/*public boolean reachable(){
		switch (this){
		case EMPTY:
		case PASSAGE:
		case WAY_UP:
		case WAY_DOWN:
			return true;
		default: return false;
		}		
	}*/
	
	public String toString(){
		return String.valueOf(token);
	}

}
