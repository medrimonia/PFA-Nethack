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
		return UNKNOWN;
	}
	
	public String toString(){
		return String.valueOf(token);
	}

}
