poisson.MODpq.log <- function(b, W, p, Z = NULL, TT, N, copula = "gaussian",
                          corrtype = "equicorrelation", rho, dof = 1) {

  if ( min(W) < 0 ) {
    stop('The adjacency matrix W contains negative values.')
  }

  if ( !is.null(Z) ) {
    Z <- model.matrix( ~., as.data.frame(Z) )
    Z <- Z[1:N, -1, drop = FALSE]
  }

  n <- 100
  W <- W / Rfast::rowsums(W)
  W[ is.na(W) ] <- 0

  y <- matrix(0, N, TT)
  nut <- matrix(0, N, TT)
  nut[, 1:p] <- 0

  if ( copula != "clayton" )  {
    if ( corrtype == "equicorrelation" ) {
	    p2R <- NULL
      R <- matrix(rho, nrow = N, ncol = N)
      diag(R) <- 1
    } else {
      p2R <- rho^( 1:(N - 1) )
      R <- toeplitz( c(1, p2R ) )
    }  ##  end  if ( corrtype == "equicorrelation" ) {
    cholR <- chol(R)
  } else  cholR <- NULL   ##  end  if ( copula != "clayton" )  {

  for ( ti in 1:p) {
    u <- PNAR::rcopula(n, N, copula, corrtype, rho, dof, cholR)
    x <- Rfast::eachrow( log(u), -exp( nut[, ti] ), oper = "/" )
    y[, ti] <- PNAR::getN(x, tt = 1)
    i <- 0
    while ( sum( is.na(y[, ti]) ) > 0 ) {
      i <- i + 2
      u <- PNAR::rcopula(i * 100 + n, N, copula, corrtype, rho, dof, cholR)
      x <- Rfast::eachrow( log(u), -exp( nut[, ti] ), oper = "/" )
      y[, ti] <- PNAR::getN(x, tt = 1)
    }
  }

  ly <- log1p(y)

  for ( ti in (p + 1):TT ) {
    X <- cbind(1, W %*% ly[, (ti - 1):(ti - p)], ly[, (ti - 1):(ti - p)], Z)
    nut[, ti] <- X %*% b
    u <- PNAR::rcopula(n, N, copula, corrtype, rho, dof, cholR)
    x <- Rfast::eachrow( log(u), -exp( nut[, ti] ), oper = "/" )
    y[, ti] <- PNAR::getN(x, tt = 1)
    i <- 0
    while ( sum( is.na(y[, ti]) ) > 0 ) {
      i <- i + 2
      u <- PNAR::rcopula(i * 100 + n, N, copula, corrtype, rho, dof, cholR)
      x <- Rfast::eachrow( log(u), -exp( nut[, ti] ), oper = "/" )
      y[, ti] <- PNAR::getN(x, tt = 1)
    }
  }

  x <- u <- NULL

  nut <- ts( t(nut) )
  y <- ts(t(y) )
  list(p2R = p2R, log_lambda = nut, y = y)
}


#############################################################################################
#############################################################################################
##  poisson.MODpq.log() --- function to generate counts from Poisson log-linear PNAR(p) model
##  with q non time-varying covarites, and with parameters:
##      b = coefficients of the models in the following order:
##         (intercept, p network effects, p ar effects, covariates)
##      W = row-normalized weighted adjacency matrix describing the network
##      p = number of lags in the model
##      Z = Nxq matrix of covariates (one for each column), where q is the number of
##          covariates in the model.
##      Time = temporal sample size
##      N = number of nodes on the network
##      copula =  from which copula generate the data:
##                "gaussian":      Gaussian copula with Toeplitz correlation matrix
##                "gaussian_rho":  Gaussian copula with constant correlation matrix
##                "student":       Student's t copula with Toeplitz correlation matrix
##                 ... we can add more
##      rho = copula parameter
##      df = degrees of freedom for Student's t copula
##  output, a list of three values:
##      y = NxTime matrix of generated counts for N time series over Time
##      log_lambda = NxTime matrix of generated Poisson log(mean) for N time series over Time
##      p2R = Toeplitz correlation matrix employed in the copula
#############################################################################################

# poisson.MODpq.log <- function(b, W, p, Z, Time, N, copula, rho, df)
# {
#
#   p2R <- rho^(1:(N-1))      ### creates column vectors of corr matrix R=(rho^|i-j|)_(i,j),
#   R=toeplitz(c(1,p2R))      ### this is a symmetric Toeplitz matrix
#
#   y=matrix(0, nrow=N, ncol=Time)
#   nu=matrix(0, nrow=N, ncol=Time)
#   nu[,1:p]=rep(0, N)
#
#   for( t in 1:p){
#
#     if(copula=="gaussian") ustart=rCopula(100, normalCopula(param=p2R, dispstr = "toep", dim=N))
#
#     if(copula=="gaussian_rho") ustart=rCopula(100, normalCopula(rho, dim = N))
#
#     if(copula=="student") ustart=rCopula(100, tCopula(param=p2R, dispstr = "toep", df=df, dim=N))
#
#     if(copula=="clayton") ustart=rCopula(100, claytonCopula(rho, dim = N))
#
#     xstart <- matrix(nrow=100, ncol=N)
#     xstart  =t(t(-log(ustart))/exp(nu[,t]))
#     y[,t] <-  apply(xstart,2, getN, tt=1)
#
#   }
#
#   ly <- log1p(y)
#
#   for (t in (p+1):Time){
#
#     X <- cbind(1, W%*%ly[,(t-1):(t-p)], ly[,(t-1):(t-p)], Z)
#
#     nu[,t]=X%*%b
#
#     if(copula=="gaussian") u=rCopula(100, normalCopula(param=p2R, dispstr = "toep", dim=N))
#
#     if(copula=="gaussian_rho") u=rCopula(100, normalCopula(rho, dim = N))
#
#     if(copula=="student") u=rCopula(100, tCopula(param=p2R, dispstr = "toep", df=df, dim=N))
#
#     if(copula=="clayton") u=rCopula(100, claytonCopula(rho, dim = N))
#
#     x <- matrix(nrow=100, ncol=N)
#     x =t(t(-log(u))/exp(nu[ ,t]))
#     y[,t] <- apply(x,2, getN,tt=1)
#
#   }
#
#   res <- list(log_lambda=nu, y=y, p2R=p2R)
#   return(res)
#
# }
