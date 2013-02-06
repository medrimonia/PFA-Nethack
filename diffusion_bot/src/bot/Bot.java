package bot;

import java.io.IOException;
import java.net.UnknownHostException;

import util.InvalidMessageException;
import util.Logger;
import util.ScoredList;
import util.Scoring;

public class Bot {
	
	private InputOutputUnit myParser;
	private int dungeonLevel;
	public Map map;
	int turn;
	
	public Bot(){
		dungeonLevel = 0;
		map = new Map();
		myParser = new InputOutputUnit();
	}
	
	public Bot(String unixSocketName)
			throws UnknownHostException, IOException{
		this();		
		myParser = new InputOutputUnit(unixSocketName);
	}

	public Bot(String hostname, int port)
			throws UnknownHostException, IOException{
		this();
		myParser = new InputOutputUnit(hostname, port);
	}

	public void treatInformation(Information i) {
		switch (i.getVariable()){
		case DUNGEON_LEVEL: dungeonLevel = (Integer)i.getValue(); break;
		case MAP: map = (Map)i.getValue(); break;
		}
	}

	public void start(){
		try{
			while(true){
				try{
					Logger.println("READING FROM SOCKET");
					nextTurn();
					Logger.println("DOING TURN");
					doTurn();
				}catch(UnknownPositionException e){
					System.out.println("The player location has not been found, Skipping turn");
				}
			}

		}catch(IOException e){
			String message = "Connection with the server has been lost";
			System.out.println(message);
		}catch(InvalidMessageException e){
			System.out.println(e.getMessage());
		}
	}
	
	public void doTurn(){
		Logger.println("Starting Turn : " + turn);
		map.actualSquare().addVisit(map);
		map.updateScores();
		Logger.println(map.toString());
		bestAction();
		turn++;
	}
	
	private ScoredList<Action> getPossibleActions(){
		ScoredList<Action> l = new ScoredList<Action>();
		// Search is always available
		double searchScore = map.actualSquare().getSearchScore();
		l.add(new Action(ActionType.SEARCH, null, searchScore));
		for (Direction dir : Direction.values()){
			Action toAdd = null;
			Square dest = map.getDest(dir);
			if (dest == null)
				continue;
			if (map.isAllowedMove(dir))
				toAdd = new Action(ActionType.MOVE,
							       dir,
							       dest.getScore() - Scoring.MOVE_COST);
			if (map.isAllowedOpen(dir)){
				toAdd = new Action(ActionType.OPEN,
							       dir,
							       dest.getScore());
			}
			if (toAdd != null)
				l.add(toAdd);
		}
		Logger.println("Nb valid choices : " + l.nbElements());
		return l;
	}
	
	public void bestAction(){
		ScoredList<Action> l = getPossibleActions();
		Action choice = l.getBestItem();
		Logger.println("Choice : " + choice);
		applyAction(choice);
	}
	
	public void randomAction(){
		ScoredList<Action> l = getPossibleActions();
		Action choice = l.getRandomItem();
		Logger.println("Choice : " + choice);
		applyAction(choice);
	}
	
	public void applyAction(Action a){
		switch(a.getType()){
		case SEARCH:
			for (Square neighbor : map.actualSquare().getNeighbors())
				neighbor.addSearch(map);
			myParser.broadcastSearch();
			return;
		case OPEN:
			map.getDest(a.getDirection()).addOpenTry();
			myParser.broadcastOpeningDoor(a.getDirection());
			return;
		case MOVE:
			myParser.broadcastMove(a.getDirection());
			return;
		}
	}
	
	public void nextTurn() throws IOException, UnknownPositionException, InvalidMessageException{
		myParser.parseNextTurn(this);
	}
	
	@Override
	public String toString(){
		StringBuffer sb = new StringBuffer();
		sb.append("dungeon_level : " + dungeonLevel + "\n");
		if (map != null)
			sb.append(map.toString() + "\n");
		return sb.toString();
	}
}
