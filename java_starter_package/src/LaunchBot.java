import util.Logger;
import bot.Bot;

public class LaunchBot{

	public static void main(String[] args){
		try{
			Bot bot = new Bot("localhost");
			bot.start();

		}catch(Exception e){
			e.printStackTrace();
		}
	}
}