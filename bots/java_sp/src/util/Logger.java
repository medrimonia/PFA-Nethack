package util;

public class Logger {
	
	public static final boolean activated = false;
	
	public static void println(String s){
		if (activated)
			System.out.println(s);
	}

}
