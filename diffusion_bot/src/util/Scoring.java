package util;

public class Scoring {
	
	public final static double DISTANCE_FACTOR = 0.8;
	
	private final static double SEARCH_VALUE = 0.98;
	private final static double VISIT_VALUE = 0.004;
	private final static double OPEN_VALUE = 0.85;
	
	public static double searchScore(int nbSearch){
		return Math.pow(SEARCH_VALUE, nbSearch);
	}
	
	public static double visitScore(int nbVisits){
		return Math.pow(VISIT_VALUE, nbVisits);
	}
	
	public static double openScore(int nbTries){
		return Math.pow(OPEN_VALUE, nbTries);
	}
}
