package bot;

import java.util.Collection;
import java.util.HashSet;

import util.Scoring;

public class Square{
	
	/**
	 * Save the position in the map, used for convenience
	 */
	private Position p;
	
	/**
	 * null for every square except stairs.
	 */
	private Map stairsDest;
	
	/**
	 * Neighbors are used so frequently that it's better to use a list like that
	 */
	private Collection<Square> neighbors;
	
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
	 * score in [0,1] representing the importance of visiting
	 * the square.
	 */
	private double visitScore;
	/**
	 * score in [0,1] representing the importance of trying to open the square
	 */
	private double openScore;
	/**
	 * score in [0,1] representing the importance of trying to force the square
	 */
	private double forceScore;
	/**
	 * score in [0,1] representing the importance of trying to force the square
	 */
	private double walkThroughScore;
	/**
	 * score in [0,1] representing the probability
	 * that something is hidden in this square (SCORR, SDOOR) 
	 */
	private double localSearchScore;
	
	private double levelChangeScore;
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
	 * Number of time the player tried to open the door
	 */
	private int nbForceTries;
	/**
	 * Number of time the player tried to walk through the door
	 */
	private int nbWalkThroughTries;
	/**
	 * Keep track of if the Square might be reached.
	 */
	private boolean reachable;
	
	public Square(char c, Position p){
		this.p = p;
		neighbors = new HashSet<Square>();
		type = SquareType.tokenToVariables(c);
		score = 0;
		internScore = 0;
		visitScore = 0;
		openScore = 0;
		localSearchScore = 0;
		searchScore = 0;
		nbSearch = 0;
		nbVisits = 0;
		nbOpenTries = 0;
		nbWalkThroughTries = 0;
		reachable = false;
		stairsDest = null;
	}
	
	// GETTERS

	public SquareType getType(){
		return type;
	}
	
	public Position getPosition(){
		return p;
	}
	
	public Collection<Square> getNeighbors(){
		return neighbors;
	}
	
	public boolean isReachable(){
		return reachable;
	}

	public Map getStairsDest() {
		return stairsDest;
	}
	
	public int getNbOpenTries(){
		return nbOpenTries;
	}
	
	public int getNbForceTries(){
		return nbForceTries;
	}
	
	public int getNbWalkThroughTries(){
		return nbWalkThroughTries;
	}
	
	public int getNbSearch(){
		return nbSearch;
	}
	
	public int getNbVisits(){
		return nbVisits;
	}
	
	public double getVisitScore(){
		return visitScore * Scoring.VISIT_SCORE;
	}
	
	public double getSearchScore(){
		return searchScore * Scoring.FOUND_SCORE;
	}
	
	public double getOpenScore(){
		return openScore * Scoring.OPEN_SCORE;
	}
	
	public double getForceScore(){
		return forceScore * Scoring.FORCE_SCORE;
	}
	
	public double getWalkThroughScore(){
		return walkThroughScore * Scoring.WALKTHROUGH_SCORE;
	}
	
	public double getLocalSearchScore(){
		return localSearchScore; 
	}
	
	public double getLevelChangeScore(){
		return levelChangeScore * Scoring.LEVEL_SCORE;
	}
	
	public double getInternScore(){
		return internScore;
	}
	
	public double getScore(){
		return score;
	}
	
	// SETTERS
	
	public void addNeighbor(Square n){
		if (n == null ||
			neighbors.contains(n))
			return;
		neighbors.add(n);
	}
	
	public void setType(SquareType t, Map m){
		if (t == type)
			return;
		type = t;
		//Update Reachable for square and neighbors
		updateReachable(m);
		for (Square n : neighbors){
			n.updateReachable(m);
		}
		//Update scores for square and neighbors
		updateOpenScore(m);
		updateForceScore(m);
		updateWalkThroughScore(m);
		updateVisitScore(m);
		updateLocalSearchScore(m);
		updateLevelChangeScore(m);
		for (Square n : neighbors){
			n.updateOpenScore(m);
			n.updateForceScore(m);
			updateWalkThroughScore(m);
			n.updateVisitScore(m);
			n.updateLocalSearchScore(m);
		}
	}
	
	public void addVisit(Map m){
		nbVisits++;
		updateVisitScore(m);
	}
	
	public void addSearch(Map m){
		nbSearch++;
		updateLocalSearchScore(m);
	}
	
	public void addOpenTry(Map m){
		nbOpenTries++;
		updateOpenScore(m);
	}
	
	public void addForceTry(Map m){
		nbForceTries++;
		updateForceScore(m);
	}
	
	public void addWalkThroughTry(Map m){
		nbWalkThroughTries++;
		updateWalkThroughScore(m);
	}
	
	public void setScore(double newScore){
		score = newScore;
	}
	
	// UPDATERS
	
	/**
	 * Reachable must only be updated when the type of a neighbor has changed
	 * @param m
	 */
	private void updateReachable(Map m){
		boolean oldValue = reachable;
		reachable = false;
		for (Direction d : Direction.values()){
			if (m.isAllowedMove(p, d))
				reachable = true;
		}
		// if reachable has changed, a lot of things must change
		if (oldValue != reachable){
			
		}
	}
	
	/**
	 * Assume that all the score functions return the appropriated values
	 */
	private void updateInternScore(Map m){
		double oldScore = internScore;
		internScore = 0;
		internScore += getVisitScore();
		internScore += getSearchScore();
		internScore += getOpenScore();
		internScore += getForceScore();
		internScore += getLevelChangeScore();
		// if score has changed, map needs update
		if (oldScore != internScore)
			m.needUpdate = true;
	}
	
	/**
	 * Assume neighborhood types are up to date
	 */
	private void updateOpenScore(Map m) {
		//TODO openScore should be lower if both sides are opened
		double oldScore = openScore;
		openScore = Scoring.openScore(this);
		if (oldScore != openScore)
			updateInternScore(m);
	}
	
	private void updateForceScore(Map m){
		double oldScore = forceScore;
		forceScore = Scoring.forceScore(this);
		if (oldScore != forceScore)
			updateInternScore(m);		
	}
	
	private void updateWalkThroughScore(Map m){
		double oldScore = walkThroughScore;
		walkThroughScore = Scoring.walkThroughScore(this);
		if (oldScore != walkThroughScore)
			updateInternScore(m);		
	}

	/**
	 * Assume that the neighborhood types and square reachable values
	 * have been updated.
	 */
	public void updateVisitScore(Map m){
		double oldValue = visitScore;
		if (isReachable())
			visitScore = Scoring.visitScore(m, p);
		if (oldValue != visitScore)
			updateInternScore(m);
	}
	
	/**
	 * Assume all neighborhood types are up to date
	 * @param m
	 */
	public void updateLocalSearchScore(Map m){
		double oldScore = localSearchScore;
		localSearchScore = Scoring.localSearchScore(m, this);
		if (localSearchScore != oldScore)
			m.updateNeighborsSearchScore(p);
	}
	
	public void updateLevelChangeScore(Map m){
		double oldScore = levelChangeScore;
		levelChangeScore = Scoring.levelChangeScore(m, this);
		if (oldScore != levelChangeScore)
			updateInternScore(m);
	}

	public void setDest(Map newDest, Map currentMap) {
		stairsDest = newDest;
		updateLevelChangeScore(currentMap);
	}
	
	public boolean isRoomUnknownExit(Map m){

		/* ROOMS EXIT
		 * .|
		 * ..
		 * .|
		 */
		Position p = getPosition();
		Square no = m.getDest(p, Direction.NORTH);
		Square so = m.getDest(p, Direction.SOUTH);
		Square we = m.getDest(p, Direction.WEST);
		Square ea = m.getDest(p, Direction.EAST);
		Square ne = m.getDest(p, Direction.NORTH_EAST);
		Square nw = m.getDest(p, Direction.NORTH_WEST);
		Square se = m.getDest(p, Direction.SOUTH_EAST);
		Square sw = m.getDest(p, Direction.SOUTH_WEST);
		if (no != null && so != null && we != null && ea != null &&
			ne != null && nw != null && se != null && sw != null){
			// Vertical exit of a place
			if (no.getType() == SquareType.VERTICAL_WALL &&
				so.getType() == SquareType.VERTICAL_WALL &&
				((se.getType() == SquareType.UNKNOWN &&
				  ea.getType() == SquareType.UNKNOWN &&
				  ne.getType() == SquareType.UNKNOWN) ||
				 (sw.getType() == SquareType.UNKNOWN &&
				  we.getType() == SquareType.UNKNOWN &&
				  nw.getType() == SquareType.UNKNOWN)))
				return true;
			// Horizontal exit of a place
			if (we.getType() == SquareType.HORIZONTAL_WALL &&
				ea.getType() == SquareType.HORIZONTAL_WALL &&
				((se.getType() == SquareType.UNKNOWN &&
				  so.getType() == SquareType.UNKNOWN &&
				  sw.getType() == SquareType.UNKNOWN) ||
				 (ne.getType() == SquareType.UNKNOWN &&
				  no.getType() == SquareType.UNKNOWN &&
				  nw.getType() == SquareType.UNKNOWN)))
				return true;
		}
		return false;
	}
	
	/**
	 * Assume all neighborhood localSearchScores are up to date
	 * @param m
	 */
	public void updateSearchScore(Map m){
		double oldScore = searchScore;
		searchScore = Scoring.environmentalSearchScore(m, p);
		if (oldScore != searchScore)
			updateInternScore(m);
	}
	
	public String toString(){
		return type.toString();
	}
}
