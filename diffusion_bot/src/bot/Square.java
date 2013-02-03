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
	
	public Square(char c){
		type = SquareType.tokenToVariables(c);
		score = 0;
		nbSearch = 0;
		nbVisits = 0;
		nbOpenTries = 0;
		updateInternScore();
		score = internScore;
	}
	
	public void addVisit(){
		nbVisits++;
	}
	
	public void addSearch(){
		nbSearch++;
	}
	
	public void addOpenTry(){
		nbOpenTries++;
	}
	
	private void updateInternScore(){
		if (type != SquareType.CLOSED_DOOR)
			internScore = (getSearchScore() +
			 		       Scoring.visitScore(nbVisits)) / 2;
		else
			internScore = Scoring.openScore(nbOpenTries);
	}
	
	public void setScore(double d){
		score = d;
	}
	
	public double getSearchScore(){
		return Scoring.searchScore(nbSearch);
	}
	
	public double getScore(){
		return score;
	}
	
	public double getInternScore(){
		return internScore;
	}

	public SquareType getType(){
		return type;
	}
	
	public String toString(){
		return type.toString();
	}
}
