package bot;

public class Information {
	
	private Variable var;
	
	private Object value;
	
	public Information(Variable var, Object value){
		this.var = var;
		this.value = value;
	}
	
	public Variable getVariable(){
		return var;
	}
	
	public Object getValue(){
		return value;
	}

}
