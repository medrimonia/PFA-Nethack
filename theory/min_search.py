import math

# Initializing squares array
square_in_range=[]
# corners
for i in range (0,4):
    square_in_range+=[4]
# borders
for i in range (4,12):
    square_in_range+=[3]
# nb_search is 0 for all initially
nb_search = [0] * 12
p_found = 0.0
p = 1.0/7.0

def favorable_cases(k):
    return square_in_range[k] * math.pow(1.0 - p, nb_search[k])
    

def possible_cases():
    total = 0.0
    for i in range(len(nb_search)):
        total += favorable_cases(i)
    return total

def best_k():
    best = -1
    max_score = 0
    for i in range(len(nb_search)):
        if (favorable_cases(i) > max_score):
            max_score = favorable_cases(i)
            best = i
    return best

epsilon = math.pow(10, -10)

p_found = [0]
r_found = [0]
n = 1
# Calculating the probabilities
while(p_found[n-1] < 1 - epsilon):
    choice = best_k()
    probability = p * favorable_cases(choice) / possible_cases()
    p_found.append(p_found[n-1] + (1-p_found[n-1]) * probability)
    nb_search[choice] += 1
    r_found.append(p_found[n] - p_found[n-1])
    print (n, p_found[n], r_found[n])
    n += 1

# Calculating the mean
p_sum = 0.0
for i in range(len(r_found)):
    p_sum += i * r_found[i]
avg = p_sum / sum(r_found)
# The '#' at beginning allow to plot without issue from gnuplot
print ("# average :", avg) 
