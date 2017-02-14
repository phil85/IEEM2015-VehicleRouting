# SETS

set E;		# Edges
set I;		# Units
set K ordered;		# Number of passes

# PARAMETERS

param B;		# Budget
param c {I};		# Cost of equipping unit i with a detector
param r {E};		# Number of passes required to cover edge j
param a {I,E};		# Number of passes of unit i through edge j
param uk {E,K};		# Increase in utility from increasing number of passes from k-1 to k

#VARIABLEN

var x {I} binary;	# =1, if unit i is equipped with detector, =0 otherwise
var u {E,K} binary;	# =1, if edge has k passes (or more), =0, otherwise

#OBJECTIVE FUNCTION

maximize COVERAGE: sum{j in E,k in K} uk[j,k]*u[j,k];

#CONSTRAINTS
subject to one {j in E}: 	sum{k in K} u[j,k] <= sum{i in I}x[i]*a[i,j];
subject to two: 		sum{i in I} c[i]*x[i] <= B;
subject to three {j in E,k in K:k<>last(K)}: 		u[j,k] >= u[j,next(k)];
