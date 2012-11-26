package bot;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Collections;

public class Bot {
	
	InputOutputUnit myParser;
	int dungeonLevel;
	Map map;
	
	public Bot(){
		dungeonLevel = 0;
		map = null;
		myParser = new InputOutputUnit();
	}
	
	public Bot(String hostname)
			throws UnknownHostException, IOException{
		this(hostname, Protocole.DEFAULT_PORT);
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
				nextTurn();
				doTurn();
			}

		}catch(IOException e){
			e.printStackTrace();
			return;
		}
	}
	
	public void doTurn(){
		randomMove();		
	}
	
	public void randomMove(){
		Direction[] myDirs = Direction.values();
		Collections.shuffle(Arrays.asList(myDirs));
		for (Direction d : myDirs){
			if (map.isAllowedMove(d)){
				myParser.broadcastMove(d);
				return;
			}
		}
	}
	
	public void nextTurn() throws IOException{
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
