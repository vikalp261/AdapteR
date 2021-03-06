#' @include FLMatrix.R
NULL

#' Row Echelon form of a Matrix.
#'
#' \code{FLMatrixREF} gives the Row Echelon form of FLMatrix objects.
#'
#' @param object is of class FLMatrix
#' @param ... any additional arguments
#' @section Constraints:
#' Input can only be a square FLMatrix with maximum dimension limitations of (1000 x 1000).
#' @return \code{FLMatrixREF} returns a FLMatrix object which is the Row Echelon form of input FLMatrix.
#' @examples
#' flmatrix <- FLMatrix("tblMatrixMulti", 5,"MATRIX_ID","ROW_ID","COL_ID","CELL_VAL")
#' resultFLMatrix <- FLMatrixREF(flmatrix)
#' @export
FLMatrixREF <- function (object, ...){
	UseMethod("FLMatrixREF", object)
}

#' @export
FLMatrixREF.FLMatrix<-function(object,...)
{

	# connection<-getFLConnection(object)
 #    ## flag1Check(connection)

	# sqlstr<-paste0(
	# 			   viewSelectMatrix(object,"a",withName="z"),
 #                   outputSelectMatrix("FLMatrixREFUdt",viewName="z",
 #                   	localName="a",includeMID=TRUE,vconnection=connection)
 #                   )

	# tblfunqueryobj <- new("FLTableFunctionQuery",
 #                        connectionName = attr(connection,"name"),
 #                        variables=list(
 #                            rowIdColumn="OutputRowNum",
 #                            colIdColumn="OutputColNum",
 #                            valueColumn="OutputVal"),
 #                        whereconditions="",
 #                        order = "",
 #                        SQLquery=sqlstr)

 #  	flm <- newFLMatrix(
 #               select= tblfunqueryobj,
 #               dims=dim(object),
 #               Dimnames=dimnames(object))
    
    flm <- constructMatrixUDTSQL(pObject=object,
                                 pFuncName="FLMatrixREFUdt",
                                 pdims=getDimsSlot(object),
                                 pdimnames=dimnames(object)
                                 )

    return(ensureQuerySize(pResult=flm,
            pInput=list(object),
            pOperator="FLMatrixREF",
            pStoreResult=TRUE))

}
