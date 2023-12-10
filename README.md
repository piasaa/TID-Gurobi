# TID-Gurobi
This proyect was done for a university research workshop (TID) where the objetive is to compare the performance of different optimization solvers. The solvers used are Gurobi in python and constrOptim in R.

The data used comes from the library Bayesm in R, OrangeJuice, it contains the sales data from 83 stores from the Chicago area
for 11 refrigerated orange juice for 121 weeks. The optimization model uses store number 2, wanting to maximize the Category Revenue of orange juice deciding the price of each product. 
Machine learning is use to predict the demand considering the log of prices, log of demand, deal and feat status to traing the regression.

The file "Gurobi Explanation" explains how to use gurobi given the optimzation model for OrangeJuice, going step by step to undestand the functions that gurobi has.

The file "Comparison_solvers" is where the Gurobi optimization is done and compared with the constrOptim results which is in "ConstrOptim11products".
"Comparison_solvers" also has the change from lineal regression to Lasso regression to predict the demand and then optimize to get more realistic results.
