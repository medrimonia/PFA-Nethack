package util;

public class InvalidMessageException extends Exception {
	
	/**
	 * 
	 */
	// From David: What is this variable? What is it used for?
	private static final long serialVersionUID = 1L;

	public InvalidMessageException(String message){
		super(message);
	}

}
