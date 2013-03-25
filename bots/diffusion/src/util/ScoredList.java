package util;

import java.util.LinkedList;
import java.util.List;

public class ScoredList<A extends Scoreable> {
	
	private List<A> l;
	private double sum;
	
	public ScoredList(){
		l = new LinkedList<A>();
		sum = 0;
	}
	
	public void add(A item){
		l.add(item);
		sum += item.getScore();
	}
	
	public A getBestItem(){
		double bestScore = Double.NEGATIVE_INFINITY;
		A bestItem = null;
		for (A item : l){
			if (item.getScore() > bestScore){
				bestScore = item.getScore();
				bestItem = item;
			}		
		}
		return bestItem;
	}
	
	public A getRandomItem(){
		double rand = Math.random() * sum;
		//System.out.println("GetRandomItem : rand = " + rand);
		double val = 0;
		for (int i = 0; i < l.size(); i++){
			val += l.get(i).getScore();
			//System.out.println("\tValue = " + val);
			if (rand <= val)
				return l.get(i);
		}
		return null;
	}
	
	public int nbElements(){
		return l.size();
	}
}
