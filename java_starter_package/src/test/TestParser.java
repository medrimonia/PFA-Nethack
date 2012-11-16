package test;

import bot.Bot;

public class TestParser {
	
	public static void main(String[] args){
		Bot b = new Bot();
		b.nextTurn();
		System.out.println(b);
		b.doTurn();
	}

}
