package util;

import bot.Direction;
import bot.Map;
import bot.Position;
import bot.Square;
import bot.SquareType;

public class Scoring {
	
	public final static double MOVE_COST = 1;
	public final static double MINIMAL_CONSERVATION = 1;
	
	public final static double VISIT_SCORE = 1;
	public final static double UNKNOWN_SCORE = 2;
	public final static double PASSAGE_SCORE = 20;
	public final static double OPEN_SCORE = 50;
	public final static double OPEN_FADING = 0.8;
	public final static double FOUND_SCORE = 250;
	
	public final static double DEAD_END_SEARCH_SCORE = 1;
	public final static double CLASSIC_SEARCH_SCORE = 0.1;
	
	/**
	 * SEARCH_K is used to smooth the probability of founding something
	 */
	private final static double SEARCH_K = 1;
	
	/**
	 * SEARCH_K is used to smooth the probability of opening something
	 */
	private final static double OPEN_K = 1;
	
	public static double smoothedProbability(int nbSuccess, int nbTries, double k){
		return (nbSuccess + k / 2) / (nbTries + k);
	}
	
	/**
	 * Return the value of a single Square when searched, abstracting from
	 * all environment.
	 * @param s
	 * @return A number between 0 and 1
	 */
	public static double localSearchScore(Square s){
		return hiddenProbability(s) * Math.pow(smoothedProbability(0, s.getNbSearch(), SEARCH_K), 3);
	}
	
	/**
	 * Return the probability that something is hidden in the specified
	 * square according to the neighborhood
	 * @param s
	 * @return A number in [0,1]
	 */
	public static double hiddenProbability(Square s){
		if (!s.getType().searchable())
			return 0;
		int nbPassages = 0;
		int nbEmpty = 0;
		// Counting neighbors passage
		for (Square neighbor : s.getNeighbors()){
			if (neighbor.getType() == SquareType.PASSAGE)
				nbPassages++;
			if (neighbor.getType() == SquareType.EMPTY)
				nbEmpty++;
		}
		if (nbPassages == 1 && nbEmpty == 0)
			return DEAD_END_SEARCH_SCORE;
		return CLASSIC_SEARCH_SCORE;
	}
	
	/**
	 * Compute the score of a search, taking into account the environment.
	 * If the square is not a reachable type, return 0.
	 * This function assume that isReachable returns an up to date value for
	 * the specified Position. Every Square of the neighborhood must have it's
	 * localSearchScore up to date.
	 * @param m The map on which the search
	 * @param p The position where the search would be performed
	 * @return A number between 0 and 1
	 */
	public static double environmentalSearchScore(Map m, Position p){
		Square src = m.getSquare(p);
		if (!src.isReachable())
			return 0;
		double score = 0;
		for (Direction d : Direction.values()){
			Square neighbor = m.getSquare(Position.add(p, d));
			if (neighbor != null)
				score += neighbor.getLocalSearchScore();
		}
		return score / 8;
		
	}
	
	public static double visitScore(Map m, Position p){
		Square s = m.getSquare(p);
		
		if (s == null || !s.isReachable() || s.getNbVisits() > 0)
			return 0;
		double score = 0;
		for (Square n : s.getNeighbors())
			if (n.getType() == SquareType.UNKNOWN)
				score += UNKNOWN_SCORE;
		if (s.getType() == SquareType.PASSAGE)
			return PASSAGE_SCORE;
		return 1;
	}
	
	public static double openScore(Square s){
		if (s.getType() != SquareType.CLOSED_DOOR) return 0;
		return Math.pow(OPEN_FADING, s.getNbOpenTries());
		//return smoothedProbability(0, s.getNbOpenTries(), OPEN_K);
	}
}
