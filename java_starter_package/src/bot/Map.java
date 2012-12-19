package bot;

public class Map {

	private Position myPosition;
	private Square[][] content;

	public Map(char[][] map) throws UnknownPositionException{
		content = new Square[map.length][map[0].length];
		for (int line = 0; line < map.length ; line++){
			for (int column = 0; column < map[line].length; column++){
				char c = map[line][column];
				if (c == '@')
					myPosition = new Position(line, column);
				content[line][column] = new Square(map[line][column]);
			}
		}
	}
	
	public boolean isAllowedMove(Direction d){
		Square dest = getSquare(Position.add(myPosition, d));
		// if dest is out of map, is a door or is out of sight, move is forbidden
		if (dest == null ||
			dest.getType() == SquareType.CLOSED_DOOR ||
			dest.getType() == SquareType.UNKNOWN)
			return false;
		switch (d){
		case NORTH:
		case SOUTH:
			return (dest.getType() != SquareType.HORIZONTAL_WALL);
		case EAST:
		case WEST:
			return (dest.getType() != SquareType.VERTICAL_WALL);
		case NORTH_EAST:
		case NORTH_WEST:
		case SOUTH_WEST:
		case SOUTH_EAST:
			return (dest.getType() != SquareType.VERTICAL_WALL &&
					dest.getType() != SquareType.HORIZONTAL_WALL);
		default: return false;
		}
	}
	
	public Square getSquare(Position p){
		int line = p.getLine();
		if (line >= content.length ||
			line < 0)
			return null;
		int col = p.getColumn();
		if (col >= content[line].length ||
			col < 0)
			return null;
		return content[line][col];
	}
	
	public Position getPlayerPosition(){
		return myPosition;
	}
	
	public String toString(){
		StringBuffer sb = new StringBuffer();
		sb.append("myPosition : " + myPosition);
		for (int line = 0; line < content.length ; line++){
			for (int column = 0; column < content[line].length; column++)
				sb.append(content[line][column].toString());
			sb.append('\n');
		}
		return sb.toString();
	}

}
