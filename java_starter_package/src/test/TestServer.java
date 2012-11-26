package test;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

import bot.Protocole;

public class TestServer {
	
	public static void main(String[] args){
		ServerSocket serverSocket = null;
		Socket clientSocket = null;
		try{
			serverSocket = new ServerSocket(Protocole.DEFAULT_PORT);
			clientSocket = serverSocket.accept();
			
			PrintWriter toClient = new PrintWriter(clientSocket.getOutputStream(), true);
			BufferedReader fromClient = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
			BufferedReader input = new BufferedReader(new InputStreamReader(System.in));
			
			String line;
			
			// Transmitting initial message
			while ((line = input.readLine()) != null){
				toClient.println(line);
			}
			
			// Receiving message from client
			while ((line = fromClient.readLine()) != null){
				System.out.println(line);
			}
			
			// Closing sockets
			clientSocket.close();
			serverSocket.close();
			
		}catch(Exception e){
			e.printStackTrace();
		}
	}

}
