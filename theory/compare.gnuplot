set xlabel "Number of actions"
set ylabel "Probability to discover the secret door"

set terminal png size 1024,768
set output "compare.png"
plot 'result_from_db' using 2 with lines lw 3 lt rgb "violet" \
		 title "Bot diffusion", \
		 'result.txt' using 2 with lines lw 3 lt rgb "orange" \
		 title "Borne inférieure"