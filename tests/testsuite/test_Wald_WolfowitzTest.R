                                        #Wald-Wolf 1s Test
sqlstr <- paste0("SELECT * FROM tblWW1SMulti WHERE DATASETID = 1")
res <- sqlQuery(connection, sqlstr)
Renv = new.env(parent = globalenv())
Renv$dat <- res$num_val
FLenv = as.FL(Renv)
                                        # Making the model.
Renv$res1 <- runs.test(Renv$dat,threshold = 6.2 )
FLenv$res1 <- WaldWolftest1s(FLenv$dat, threshold = 6.2)

test_that("Wald-Wolfowitz One Sample Test:",{
    result = eval_expect_equal({
        p.val <- res1$p.value
        z <- res1$statistic
    },Renv,FLenv,
    noexpectation=c("res1"),
    expectation = c("p.val","z"),
    check.attributes=FALSE,
    verbose = TRUE)
    })




                                        #Wald Wolf 1s Test:
library(randtests)
data(sweetpotato)
Renv = new.env(parent = globalenv())
Renv$yield <- sweetpotato$yield
FLenv = as.FL(Renv)
Renv$res1 <- runs.test(Renv$yield)
FLenv$res1 <- WaldWolftest1s(FLenv$yield)

test_that("Wald-Wolfowitz One Sample Test:",{
    result = eval_expect_equal({
        p.val <- res1$p.value
        z <- res1$statistic
    },Renv,FLenv,
    noexpectation=c("res1"),
    expectation = c("p.val","z"),
    check.attributes=FALSE,
    verbose = TRUE)
    })

                                        #Wald WOlf 2s Test:
sqlstr <- paste0("SELECT * FROM tblWW2SMulti WHERE DATASETID = 1")
res <- sqlQuery(connection, sqlstr)
Renv = new.env(parent = globalenv())

Renv$x <- res$num_val[res$groupid == 1]
Renv$y <- res$num_val[res$groupid == 2]
FLenv = as.FL(Renv)
Renv$res1 <- runs.test(Renv$x, Renv$y, alternative = "two.sided")
FLenv$res1 <- WaldWolftest2s(FLenv$x, FLenv$y)

test_that("Wald-Wolfowitz two Sample Test:",{
    result = eval_expect_equal({
        p.val <- res1$p.value
        z <- res1$statistic
        
    },Renv,FLenv,
    noexpectation=c("res1"),
    expectation =c( "p.val", "z"),
    check.attributes=FALSE,
    verbose = TRUE)
})




#Wald-Wolf Test 2s

Renv = new.env(parent = globalenv())
Renv$a = c(35,44,39,50,48,29,60,75,49,66)
Renv$b = c(17, 23, 13, 24, 33, 21, 18, 16, 32)
FLenv = as.FL(Renv)
FLenv$res1 <- WaldWolftest2s(FLenv$a, FLenv$b)
Renv$res1 <- runs.test(Renv$a, Renv$b, alternative = "two.sided")



                                        # source: http://www.statext.com/practice/WaldWolfowitzRunsTestTwo02.php
                                        #result of source gives Z = -2.83 which is same as computed by FL Test

test_that("Wald-Wolfowitz two Sample Test:",{
    result = eval_expect_equal({
        p.val <- res1$p.value
        z <- res1$statistic
        
    },Renv,FLenv,
    noexpectation=c("res1"),
    expectation =c( "p.val", "z"),
    check.attributes=FALSE,
    verbose = TRUE)
})