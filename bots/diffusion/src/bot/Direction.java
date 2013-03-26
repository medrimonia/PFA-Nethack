package bot;

public enum Direction {
	NORTH('k',-1,0),
	NORTH_EAST('u',-1,1),
	EAST('l',0,1),
	SOUTH_EAST('n',1,1),
	SOUTH('j',1,0),
	SOUTH_WEST('b',1,-1),
	WEST('h',0,-1),
	NORTH_WEST('y',-1,-1);
	
	private char value;
	private int deltaLine;
	private int deltaColumn;
	
	Direction(char c, int deltaLine, int deltaColumn){
		value = c;
		this.deltaLine = deltaLine;
		this.deltaColumn = deltaColumn;
	}
	
	public Direction opposite(){
		for (Direction d : Direction.values()){
			if (d.deltaColumn == - deltaColumn &&
			    d.deltaLine == -deltaLine)
				return d;
		}
		return null;
	}
	
	public char getValue(){
		return value;
	}
	
	public int getDeltaLine(){
		return deltaLine;
	}
	public int getDeltaColumn(){
		return deltaColumn;
	}

}
