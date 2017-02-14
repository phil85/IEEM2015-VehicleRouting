# SETS

set E;		# Edges
set I;		# Units

# PARAMETERS

param B;		# Budget
param c {I};		# Cost of equipping unit i with a detector
param r {E};		# Number of passes required to cover edge j
param a {I,E};		# Number of passes of unit i through edge j

#VARIABLEN

var x {I} binary;	# =1, if unit i is equipped with detector, =0 otherwise
var y {E} binary;	# =1, if edge j is covered, =0, otherwise

#OBJECTIVE FUNCTION

maximize COVERAGE: sum{j in E} y[j];

#CONSTRAINTS

subject to one {j in E}: 	r[j]*y[j] <= sum{i in I}x[i]*a[i,j];
subject to two: 		sum{i in I} c[i]*x[i] <= B;
