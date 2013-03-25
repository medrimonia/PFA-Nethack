import bot.Bot;
import bot.Protocole;

public class LaunchBot{

	public static void main(String[] args){
		try{
			Bot bot;
			if (args.length > 0)
				bot = new Bot(args[0]);
			else
				bot = new Bot(Protocole.UNIX_SOCKET_NAME);
			bot.start();

		}catch(Exception e){
			e.printStackTrace();
		}
	}
}