#' @include FLMatrix.R
NULL

#' QR Decomposition.
#'
#' The QR decomposition involves factorizing a matrix into QMatrix and RMatrix.
#'
#' \code{qr} replicates the equivalent qr() generic function.\cr
#' @param object is of class FLMatrix
#' @param ... any additional arguments
#' @section Constraints:
#' Input can only be with maximum dimension limitations of (700 x 700).
#' @return \code{qr} returns a list of five components:
#' \item{qr}{a FLMatrix with the same dimensions as \code{object}. The upper triangle contains the R of the decomposition 
#' and the lower triangle contains information on the Q of the decomposition (stored in compact form)}
#' \item{qraux}{a FLVector of length ncol(\code{object}) which contains additional information on Q.}
#' \item{rank}{the FLVector giving rank of \code{object}}
#' \item{QMatrix}{the resulting Q Matrix stored in-database as FLMatrix}
#' \item{RMatrix}{the resulting R Matrix stored in-database as FLMatrix}
#' @examples
#' flmatrix <- FLMatrix(getTestTableName("tblMatrixMulti"), 5,"MATRIX_ID","ROW_ID","COL_ID","CELL_VAL")
#' resultList <- qr(flmatrix)
#' resultList$qr
#' resultList$qraux
#' resultList$rank
#' resultList$pivot
#' @export
qr<-function(object, ...){
	UseMethod("qr",object)
}

#' @export
qr.FLMatrix<-function(object,...)
{
	connection<-getFLConnection(object)
	## flag1Check(connection)
	## flag3Check(connection)
    MID1 <- getMaxMatrixId(connection)


    # sqlstr <- paste0(
    #                  viewSelectMatrix(object, "a","z"),
    #                  outputSelectMatrix("FLQRDecompUdt",viewName="z",localName="a",
    #                 	outColNames=list("OutputMatrixID","OutputRowNum",
    #                 		"OutputColNum","OutputValQ","OutputValR"),
    #                 	whereClause="")
    #                )
    
    sqlstr <- constructMatrixUDTSQL(pObject=object,
                                    pFuncName="FLQRDecompUdt",
                                    pdims=getDimsSlot(object),
                                    pdimnames=dimnames(object),
                                    pReturnQuery=TRUE
                                    )

    sqlstr <- gsub("'%insertIDhere%'",MID1,sqlstr)

    sqlstr <- ensureQuerySize(pResult=sqlstr,
	                           pInput=list(object),
	                           pOperator="qr")

    tempResultTable <- cacheDecompResults(pFuncName="FLQRDecompUdt",
                                          pQuery=sqlstr)

 #    vtblName <- gen_unique_table_name("tblQRDecompResult")
 #    tempResultTable <- createTable(pTableName=vtblName,
 #                                    pColNames=c("OutputMatrixID","OutputRowNum",
 #                                                "OutputColNum","OutputValQ","OutputValR"),
 #                                    pColTypes=c("INT","INT","INT","FLOAT","FLOAT"),
 #                                    pPrimaryKey=c("OutputMatrixID","OutputRowNum",
 #                                                "OutputColNum")
 #                                    )

	# tempResultTable <- insertIntotbl(pTableName=vtblName,
 #                                    pSelect=sqlstr)
	
 #    tempResultTable <- vtblName
	#calculating QRMatrix

    sqlstrQR <-paste0(" SELECT ",MID1," AS MATRIX_ID, \n ",
					         "OutputRowNum AS rowIdColumn, \n ",
					          "OutputColNum AS colIdColumn, \n ",
					          "OutputValQ AS valueColumn \n ",
					  " FROM ",tempResultTable,
					 " WHERE OutputRowNum > OutputColNum \n ",
					 " UNION ALL \n ",
					 " SELECT ",MID1," AS MATRIX_ID, \n ",
					         "OutputRowNum AS rowIdColumn, \n ",
					         "OutputColNum AS colIdColumn, \n ",
					         "OutputValR AS valueColumn \n ",
					  " FROM ",tempResultTable,
					 " WHERE OutputRowNum <= OutputColNum ")

    ##@phani:- insert INTO tablename <select with union clause> not working on hive

    tblfunqueryobj <- new("FLTableFunctionQuery",
                        connectionName = attr(connection,"name"),
                        variables=list(
                            rowIdColumn="rowIdColumn",
                            colIdColumn="colIdColumn",
                            valueColumn="valueColumn"),
                        whereconditions="",
                        order = "",
                        SQLquery=sqlstrQR)

  	flm <- newFLMatrix(
            select= tblfunqueryobj,
            dims=dim(object),
            Dimnames=dimnames(object))

  	# QRMatrix <- store(object=flm)
    QRMatrix <- flm

    #calculating qraux
	table <- FLTable(tempResultTable,
		             "OutputRowNum",
		             whereconditions=paste0(tempResultTable,".OutputRowNum = ",
                                            tempResultTable,".OutputColNum ")
		             )

	qraux <- table[,"OutputValQ"]
	
	#calculating rank
	r<-rankMatrix(object)

	# calculating Q FLmatrix
    Q<-FLMatrix(connection = connection, 
           table_name = tempResultTable, 
           matrix_id_value = "",
           matrix_id_colname = "", 
           row_id_colname = "OutputRowNum", 
           col_id_colname = "OutputColNum", 
           cell_val_colname = "OutputValQ",
           whereconditions="")


    # calculating U FLmatrix
    R<-FLMatrix(connection = connection, 
           table_name = tempResultTable, 
           matrix_id_value = "",
           matrix_id_colname = "", 
           row_id_colname = "OutputRowNum", 
           col_id_colname = "OutputColNum", 
           cell_val_colname = "OutputValR",
           whereconditions="")

	resultList <- list(qr = QRMatrix,
					   rank = r,
					   qraux = qraux,
					   pivot= 1:ncol(object),
                       Q=Q,
                       R=R,
                       X=object)

	return(resultList)
}

#' @export
setGeneric("qr.Q",function(qr,complete=FALSE,...)
  standardGeneric("qr.Q"))

setMethod("qr.Q",signature(qr="list"),
    function(qr,complete=FALSE,...){
        if(is.FLMatrix(qr$qr) &&
            !is.null(qr$Q))
        return(qr$Q)
        else return(base::qr.Q(qr=qr,
            complete=complete,...))
        })

setMethod("qr.Q",signature(qr="ANY"),
    function(qr,complete=FALSE,...){
        return(base::qr.Q(qr=qr,
            complete=complete,...))
        })

#' @export
setGeneric("qr.R",function(qr,complete=FALSE,...)
  standardGeneric("qr.R"))

setMethod("qr.R",signature(qr="list"),
    function(qr,complete=FALSE,...){
        if(is.FLMatrix(qr$qr) &&
            !is.null(qr$R))
        return(qr$R)
        else return(base::qr.R(qr=qr,
            complete=complete,...))
        })
setMethod("qr.R",signature(qr="ANY"),
    function(qr,complete=FALSE,...){
        return(base::qr.R(qr=qr,
            complete=complete,...))
        })

#' @export
setGeneric("qr.X",function(qr,complete=FALSE,...)
  standardGeneric("qr.X"))

#' @export
setMethod("qr.X",signature(qr="list"),
    function(qr,complete=FALSE){
        if(is.FLMatrix(qr$qr) &&
            !is.null(qr$X))
        return(qr$X)
        else return(base::qr.X(qr=qr,
            complete=complete,...))
        })
setMethod("qr.X",signature(qr="ANY"),
    function(qr,complete=FALSE,...){
        return(base::qr.X(qr=qr,
            complete=complete,...))
        })

#' @export
setGeneric("qr.coef",function(qr,y)
  standardGeneric("qr.coef"))

setMethod("qr.coef",signature(qr="list"),
          function(qr,y){
    if(!is.FLMatrix(qr$qr))
    return(base::qr.coef(qr=qr,y=y))

    if(!is.FLMatrix(y))
    y <- as.FLMatrix(y)

    R <- qr.R(qr)
    Q <- qr.Q(qr)

    return(solve(R)%*%t(Q)%*%y)
    })
setMethod("qr.coef",signature(qr="ANY"),
    function(qr,y){
        return(base::qr.coef(qr=qr,
            y=y))
        })

#' @export
setGeneric("qr.solve",function(a,b,tol=0.0000001)
  standardGeneric("qr.solve"))

setMethod("qr.solve",signature(a="ANY",b="ANY"),
    function(a,b,tol=0.0000001){
      if(!(is.FLMatrix(a)||is.FLMatrix(b)))
        return(base::qr.solve(a=a,b=b,
                tol=tol))
      else{
        if(!is.FLMatrix(a)) a <- as.FLMatrix(a)
        if(!is.FLMatrix(b)) b <- as.FLMatrix(b)
        qrdecomp <- qr(a)
        return(qr.coef(qrdecomp,b))
      }
        })

#' @export
setGeneric("qr.fitted",function(qr,y)
  standardGeneric("qr.fitted"))

setMethod("qr.fitted",signature(qr="list"),
          function(qr,y){
    if(!is.FLMatrix(qr$qr))
    return(base::qr.fitted(qr=qr,y=y))

    if(!is.FLMatrix(y))
    y <- as.FLMatrix(y)

    return(qr$X %*% qr.coef(qr,y))
    })
setMethod("qr.fitted",signature(qr="ANY"),
    function(qr,y){
        return(base::qr.fitted(qr=qr,
            y=y))
        })

#' @export
setGeneric("qr.resid",function(qr,y)
  standardGeneric("qr.resid"))

setMethod("qr.resid",signature(qr="list"),
  function(qr,y){
    if(!is.FLMatrix(qr$qr))
    return(base::qr.resid(qr=qr,y=y))

    if(!is.FLMatrix(y))
    y <- as.FLMatrix(y)

    return(qr.fitted(qr,y)-y)
    })
setMethod("qr.resid",signature(qr="ANY"),
    function(qr,y){
        return(base::qr.resid(qr=qr,
            y=y))
        })

#' @export
setGeneric("qr.qy",function(qr,y)
  standardGeneric("qr.qy"))

setMethod("qr.qy",signature(qr="list"),
  function(qr,y){
    if(!is.FLMatrix(qr$qr))
    return(base::qr.qy(qr=qr,y=y))

    if(!is.FLMatrix(y))
    y <- as.FLMatrix(y)

    return(qr.Q(qr) %*% y)
    })
setMethod("qr.qy",signature(qr="ANY"),
    function(qr,y){
        return(base::qr.qy(qr=qr,
            y=y))
        })

#' @export
setGeneric("qr.qty",function(qr,y)
  standardGeneric("qr.qty"))

setMethod("qr.qty",signature(qr="list"),
  function(qr,y){
    if(!is.FLMatrix(qr$qr))
    return(base::qr.qty(qr=qr,y=y))

    if(!is.FLMatrix(y))
    y <- as.FLMatrix(y)

    return(t(qr.Q(qr)) %*% y)
    })
setMethod("qr.qty",signature(qr="ANY"),
    function(qr,y){
        return(base::qr.qty(qr=qr,
            y=y))
        })

## caches the decomposition results from UDT's in a temporary table
cacheDecompResults <- function(pFuncName,pQuery){
    vOutColnames <- getMatrixUDTMapping(pFuncName)[["args"]]

    pFuncNameTrim <- gsub("Udt","",gsub("FL","",pFuncName))
    vlen <- length(vOutColnames)-3
    vtblName <- gen_unique_table_name(pFuncNameTrim)
    tempResultTable <- createTable(pTableName=vtblName,
                                    pColNames=vOutColnames,
                                    pColTypes=c(rep("INT",3),rep("FLOAT",vlen)),
                                    pPrimaryKey=c("OutputMatrixID","OutputRowNum","OutputColNum")
                                    )

    tempResultTable <- insertIntotbl(pTableName=vtblName,
                                    pSelect=pQuery)
    
    return(vtblName)
}
