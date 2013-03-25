package bot;

import java.util.HashMap;

public enum Variable {
	MAP("MAP"),
	MAP_HEIGHT("MAP_HEIGHT"),
	MAP_WIDTH("MAP_WIDTH"),
	ACTION_RESULT("ACTION_RESULT"),
	DUNGEON_LEVEL("DUNGEON_LEVEL"),
	UNKNOWN("?");
	
	private String token;
	private static HashMap<String,Variable> myVariables;
	
	Variable(String token){
		this.token = token;
	}
	
	public String getToken(){
		return token;
	}
	
	static{
		myVariables = new HashMap<String,Variable>();
		for (Variable v : Variable.values()){
			myVariables.put(v.token, v);
		}
	}
	
	public static Variable tokenToVariables(String token){
		if (myVariables.containsKey(token))
			return myVariables.get(token);
		return UNKNOWN;
	}

}
