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
	
}
