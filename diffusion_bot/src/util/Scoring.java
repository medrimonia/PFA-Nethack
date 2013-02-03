package util;

public class Scoring {
	
	public final static double DISTANCE_FACTOR = 0.6;
	
	private final static double SEARCH_VALUE = 0.9;
	private final static double VISIT_VALUE = 0.4;
	private final static double OPEN_VALUE = 0.8;
	
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
