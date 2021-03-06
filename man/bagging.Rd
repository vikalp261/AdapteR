% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bagging.R
\name{bagging}
\alias{bagging}
\title{Applies the Bagging algorithm to a dataset}
\usage{
bagging(formula, data, ...)
}
\arguments{
\item{formula}{formula specifying the independent and dependent variable columns}

\item{data}{FLTable}

\item{mfinal}{an integer, the number of iterations
for which boosting is run or the number of trees to use.
Defaults to mfinal=5 iterations.}

\item{control}{options that control details of the rpart algorithm. See rpart for more details.}
}
\value{
An object of class "FLBagging" which has details about the trees generated
and the number of votes in bag corresponding to every ObsID.
}
\description{
Fits the Bagging algorithm proposed by Breiman in
1996 using classification trees as single classifiers.
}
\examples{
flt<-FLTable("tblDecisionTreeMulti","ObsID","VarID","Num_Val")
flobj<-bagging(flt, formula = -1~.,mfinal=5)
}
