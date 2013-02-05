package test;

import bot.Bot;

public class TestBot {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Bot b = new Bot();
		int height = 3;
		int width = 5;
		b.map.updateSize(height, width);
		for (int col = 0; col < width; col++)
			b.map.updateSquare(0, col, '-');
		b.map.updateSquare(1, 0, '|');
		for (int col = 1; col < width - 1; col++)
			b.map.updateSquare(1, col, '.');
		b.map.updateSquare(1, width - 1, '|');
		for (int col = 0; col < width; col++)
			b.map.updateSquare(2, col, '-');
		b.map.updateSquare(1, 1, '@');
		System.out.println(b.map);
		b.doTurn();
		System.out.println(b.map);
		
	}

}
