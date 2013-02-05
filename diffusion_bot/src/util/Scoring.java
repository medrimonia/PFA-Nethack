package util;

import bot.Direction;
import bot.Map;
import bot.Position;
import bot.Square;

public class Scoring {
	
	public final static double MOVE_COST = 0.005;
	
	public final static double VISIT_SCORE = 1;
	public final static double OPEN_SCORE = 50;
	public final static double FOUND_SCORE = 100;
	
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
		return s.getInternProbability() * smoothedProbability(0, s.getNbSearch(), SEARCH_K);
	}
	
	/**
	 * Compute the score of a search, taking into account the environment.
	 * If the square is not a reachable type, return 0.
	 * @param m The map on which the search
	 * @return A number between 0 and 1
	 */
	public static double environmentalSearchScore(Map m, Position p){
		Square src = m.getSquare(p);
		if (!src.getType().reachable())
			return 0;
		double score = 0;
		for (Direction d : Direction.values()){
			Square neighbor = m.getSquare(Position.add(p, d));
			if (neighbor != null)
				score += neighbor.getLocalSearchScore();
		}
		return score / 8;
		
	}
	
	public static double visitScore(int nbVisits){
		if (nbVisits == 0)
			return 1;
		return 0;
	}
	
	public static double openScore(Square s){
		return smoothedProbability(0, s.getNbOpenTries(), OPEN_K);
	}
}
