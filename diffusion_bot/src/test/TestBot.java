package test;

import bot.Bot;

public class TestBot {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Bot b = new Bot();
		int height = 8;
		int width = 7;
		b.map.updateSize(height, width);
		for (int col = 1; col < width - 1; col++)
			b.map.updateSquare(2, col, '-');
		for (int line = 3 ; line < height - 1; line++){
			b.map.updateSquare(line, 1, '|');
			b.map.updateSquare(line, width -2, '|');
		}
		for (int line = 3; line < height - 1; line++)
			for (int col = 2; col < width - 2; col++)
				b.map.updateSquare(line, col, '.');
		for (int col = 1; col < width - 1; col++)
			b.map.updateSquare(height - 1, col, '-');
		// DETAILS
		b.map.updateSquare(1, 2, '#');
		b.map.updateSquare(2, 2, '|');
		b.map.updateSquare(3, 2, '<');
		b.map.updateSquare(4, 2, '@');
		System.out.println(b.map);
		b.doTurn();
		System.out.println(b.map);
		
	}

}
