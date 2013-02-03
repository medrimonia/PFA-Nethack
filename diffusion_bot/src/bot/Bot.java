package bot;

import java.io.IOException;
import java.net.UnknownHostException;

import util.InvalidMessageException;
import util.Logger;
import util.RandomList;

public class Bot {
	
	InputOutputUnit myParser;
	int dungeonLevel;
	Map map;
	
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
		map.actualSquare().addVisit();
		map.updateScores();
		randomAction();
	}
	
	public void randomAction(){
		RandomList<Action> l = new RandomList<Action>();
		// Search is always available
		double searchScore = map.actualSquare().getSearchScore();
		for (Direction dir : Direction.values()){
			Square dest = map.getDest(dir);
			if (dest != null)
				searchScore += dest.getSearchScore();
		}
		searchScore = searchScore / 3;// 9 squares taken into account
		l.add(new Action(ActionType.SEARCH, null, searchScore));
		for (Direction dir : Direction.values()){
			Action toAdd = null;
			Square dest = map.getDest(dir);
			if (dest == null)
				continue;
			if (map.isAllowedMove(dir))
				toAdd = new Action(ActionType.MOVE,
							       dir,
							       dest.getScore());
			if (map.isAllowedOpen(dir)){
				Logger.println("Opening to " + dir + " is allowed.");
				toAdd = new Action(ActionType.OPEN,
							       dir,
							       dest.getOpenScore() * 1000);
			}
			if (toAdd != null)
				l.add(toAdd);
		}
		System.out.println("NbValidActions : " + l.nbElements());
		Action choice = l.getRandomItem();
		System.out.println("Choice : " + choice);
		applyAction(choice);
	}
	
	public void applyAction(Action a){
		switch(a.getType()){
		case SEARCH:
			map.actualSquare().addSearch();
			myParser.broadcastSearch();
			return;
		case OPEN:
			Logger.println("Trying to open a door!");
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
