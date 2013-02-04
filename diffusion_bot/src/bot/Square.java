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
		updateInternScore();
	}
	
	public void addSearch(){
		nbSearch++;
		updateInternScore();
	}
	
	public void addOpenTry(){
		nbOpenTries++;
		updateInternScore();
	}
	
	private void updateInternScore(){
		internScore = 0;
		internScore += getVisitScore();
		internScore += getSearchScore();
		internScore += getOpenScore();
	}
	
	public double getVisitScore(){
		switch (type){
		case EMPTY:
		case PASSAGE:
		case WAY_UP:
		case WAY_DOWN:
			return Scoring.visitScore(nbVisits);
		default: return 0;
		}
	}
	
	/*TODO might be improved (search has a range, value of search on a square
	 * should be affected by neighboors.
	 */
	
	public double getSearchScore(){
		switch (type){
		case UNKNOWN:
		case VERTICAL_WALL:
		case HORIZONTAL_WALL:
			return Scoring.searchScore(nbSearch);
		default: return 0;
		}
	}
	
	public double getOpenScore(){
		switch (type){
		case CLOSED_DOOR:
			return Scoring.openScore(nbOpenTries);
		default: return 0;
		}
	}
	
	public void setScore(double d){
		score = d;
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
