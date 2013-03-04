package util;

public class InvalidMessageException extends Exception {
	
	/** Avoiding Warnings because Exception implements java.io.Serializable
	 * Source : http://stackoverflow.com/questions/285793/what-is-a-serialversionuid-and-why-should-i-use-it
	 */
	private static final long serialVersionUID = 1L;

	public InvalidMessageException(String message){
		super(message);
	}

}
