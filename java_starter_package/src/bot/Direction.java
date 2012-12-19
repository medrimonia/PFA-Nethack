package bot;

public enum Direction {
	NORTH("NORTH",-1,0),
	NORTH_EAST("NORTH_EAST",-1,1),
	EAST("EAST",0,1),
	SOUTH_EAST("SOUTH_EAST",1,1),
	SOUTH("SOUTH",1,0),
	SOUTH_WEST("SOUTH_WEST",1,-1),
	WEST("WEST",0,-1),
	NORTH_WEST("NORTH_WEST",-1,-1);
	
	private String value;
	private int deltaLine;
	private int deltaColumn;
	
	Direction(String s, int deltaLine, int deltaColumn){
		value = s;
		this.deltaLine = deltaLine;
		this.deltaColumn = deltaColumn;
	}
	
	public String getValue(){
		return value;
	}
	
	public int getDeltaLine(){
		return deltaLine;
	}
	public int getDeltaColumn(){
		return deltaColumn;
	}

}
