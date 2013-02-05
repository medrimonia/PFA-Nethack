package bot;

import util.Scoring;

public class Square {
	
	private SquareType type;
	/**
	 * Score is always supposed to be in [0,1]
	 * score might depend of adjacent squares
	 */
	private double score;
	/**
	 * Intern score is always supposed to be in [0,1]
	 * Intern score does not depend of adjacent squares
	 */
	private double internScore;
	/**
	 * Calculate a score in [0,1] representing the probability
	 * that something is hidden in this square (SCORR, SDOOR) 
	 */
	private double localSearchScore;
	/**
	 * A score in [0,1] specifying the probability of finding something
	 * hidden in the neighborhood when performing a search on this square
	 */
	private double searchScore;
	/**
	 * Each time a search is done in a nearbySquare, this value is incremented.
	 */
	private int nbSearch;
	/**
	 * Value of nb_visits corresponds to the number of turn spent on this
	 * square (moving on a square count as 1 turn)
	 */
	private int nbVisits;
	/**
	 * Number of time the player tried to open the door
	 */
	private int nbOpenTries;
	/**
	 * Secret probability describe the probability according to the 
	 * neighborhood, it must be updated	
	 */
	private double internProbability;
	
	public Square(char c){
		type = SquareType.tokenToVariables(c);
		score = 0;
		nbSearch = 0;
		nbVisits = 0;
		nbOpenTries = 0;
		internProbability = 0.01;
		localSearchScore = 0;
		searchScore = 0;
		updateInternScore();
		score = internScore;
	}
	
	public void addVisit(){
		nbVisits++;
		updateInternScore();
	}
	
	public void addSearch(Map m, Position p){
		nbSearch++;
		updateLocalSearchScore(m, p);
	}
	
	public void updateLocalSearchScore(Map m, Position p){
		double oldScore = localSearchScore;
		localSearchScore = Scoring.localSearchScore(this);
		if (localSearchScore != oldScore)
			m.updateNeighboorsSearchScore(p);
	}
	
	public void updateSearchScore(Map m, Position p){
		searchScore = Scoring.environmentalSearchScore(m, p);
		updateInternScore();
	}
	
	public void addOpenTry(){
		nbOpenTries++;
		updateInternScore();
	}
	
	public int getNbOpenTries(){
		return nbOpenTries;
	}
	
	public void setInternProbability(Map m, Position p, double newProbability){
		double oldProbability = internProbability;
		internProbability = newProbability;
		if (oldProbability != internProbability)
			updateLocalSearchScore(m, p);
	}
	
	public double getInternProbability(){
		return internProbability;
	}
	
	private void updateInternScore(){
		internScore = 0;
		internScore += getVisitScore();
		internScore += getSearchScore();
		internScore += getOpenScore();
	}
	
	public double getVisitScore(){
		if (type.reachable())
			return Scoring.visitScore(nbVisits) * Scoring.VISIT_SCORE;
		return 0;
	}
	
	public double getSearchScore(){
		return searchScore * Scoring.FOUND_SCORE;
	}
	
	public double getOpenScore(){
		if (type.openable())
			return Scoring.openScore(this) * Scoring.OPEN_SCORE;
		return 0;
	}
	
	public double getLocalSearchScore(){
		return localSearchScore; 
	}
	
	public void setScore(double newScore){
		score = newScore;
	}
	
	public double getScore(){
		return score;
	}
	
	public double getInternScore(){
		return internScore;
	}
	
	public int getNbSearch(){
		return nbSearch;
	}

	public SquareType getType(){
		return type;
	}
	
	public String toString(){
		return type.toString();
	}
}
