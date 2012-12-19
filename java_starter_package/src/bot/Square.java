package bot;

public class Square {
	
	private SquareType type;
	
	public Square(char c){
		type = SquareType.tokenToVariables(c);
	}

	public SquareType getType(){
		return type;
	}
	
	public String toString(){
		return type.toString();
	}
}
