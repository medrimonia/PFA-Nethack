package util;

public class Scoring {
	
	public final static double DISTANCE_FACTOR = 0.9;
	
	private final static double SEARCH_VALUE = 0.98;
	private final static double VISIT_VALUE = 0.004;
	private final static double OPEN_VALUE = 0.85;
	/** In order to avoid permanent way and back, steps are crossed
	 * every SLICE_SIZE steps
	 */
	private final static double SLICE_SIZE = 3;
	
	public static double searchScore(int nbSearch){
		return Math.pow(SEARCH_VALUE, SLICE_SIZE * (nbSearch % SLICE_SIZE));
	}
	
	public static double visitScore(int nbVisits){
		return Math.pow(VISIT_VALUE, SLICE_SIZE * (nbVisits % SLICE_SIZE));
	}
	
	public static double openScore(int nbTries){
		return Math.pow(OPEN_VALUE, SLICE_SIZE * (nbTries % SLICE_SIZE));
	}
}
