package bot;

public class Position {
	private final int line;
	private final int column;
	
	public Position(int line, int column){
		this.line = line;
		this.column = column;
	}
	
	public int getLine(){
		return line;
	}
	
	public int getColumn(){
		return column;
	}
	
	public static Position add(Position p,Direction d){
		return new Position(p.getLine() + d.getDeltaLine(),
							p.getColumn() + d.getDeltaColumn());
	}
	
	public String toString(){
		return "(" + line + " " + column + ")";
	}
	
	public boolean equals(Object o){
		if (!(o instanceof Position))
			return false;
		Position p = (Position)o;
		return (p.line == line && p.column == column);
	}
	
}
