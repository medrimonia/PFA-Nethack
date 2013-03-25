package test;

import bot.Bot;

public class TestParser {
	
	public static void main(String[] args){
		try{
			Bot b;
			if (args.length > 0 &&
					args[0].equals("server"))
				b = new Bot("localhost");
			else
				b = new Bot();
			b.nextTurn();
			b.doTurn();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

}
