################################################################################
################################################################################
##  logl_linpq() --- function for the computation of log-likelihood of the linear
##  PNAR model with p lags and q covariates. Inputs:
##     b = parameters of the models in the following order:
##        (intercept, p network effects, p ar effects, covariates)
##     N = number of nodes on the network
##     TT = temporal sample size
##     y = NxTT multivariate count time series
##     W = NxN row-normalized weighted adjacency matrix describing the network
##     p = number of lags in the model
##     Z = Nxq matrix of covariates (one for each column), where q is the number of
##         covariates in the model. They must be non-negative
##  output:
##     g = (-1)* independence quasi log-likelihood
################################################################################

.logl_linpq <- function(b, N, TT, y, W, wy, p, Z) {
  lambdat <- as.vector(wy %*% b)
  - sum( as.vector( y[, -c(1:p)] ) * log(lambdat) - lambdat )
}

################################################################################
################################################################################
##  scor_linpq() --- function for the computation of score of the linear
##  PNAR model with p lags and q covariates. Inputs:
##     b = parameters of the models in the following order:
##        (intercept, p network effects, p ar effects, covariates)
##     N = number of nodes on the network
##     TT = temporal sample size
##     y = NxTT multivariate count time series
##     W = NxN row-normalized weighted adjacency matrix describing the network
##     p = number of lags in the model
##     Z = Nxq matrix of covariates (one for each column), where q is the number of
##         covariates in the model. They must be non-negative
##  output:
##     ss = (-1)* vector of quasi score
################################################################################


.scor_linpq <- function(b, N, TT, y, W, wy, p, Z) {
  lambdat <- as.vector( wy %*% b)
  a <-  - Rfast::eachcol.apply(wy, ( as.vector(y[, -c(1:p)]) - lambdat ) / lambdat )
  matrix(a, 2 * p + 1 + max( 0, ncol(Z) ), 1)
}

################################################################################
################################################################################
##  hess_linpq() --- function for the computation of Hessian matrix of the
##  linear PNAR model with p lags and q covariates. Inputs:
##     b = parameters of the models
##     N = number of nodes on the network
##     TT = temporal sample size
##     y = NxTT multivariate count time series
##     W = NxN row-normalized weighted adjacency matrix describing the network
##     p = number of lags in the model
##     Z = Nxq matrix of covariates (one for each column), where q is the number of
##         covariates in the model. They must be non-negative
##  output:
##     hh = (-1)*Hessian matrix
################################################################################

################################################################################
################################################################################
##  outer_linpq() --- function for the computation of information matrix of the
##  linear PNAR model with p lags and q covariates. Inputs:
##     b = parameters of the models
##     N = number of nodes on the network
##     TT = temporal sample size
##     y = NxTT multivariate count time series
##     W = NxN row-normalized weighted adjacency matrix describing the network
##     p = number of lags in the model
##     Z = Nxq matrix of covariates (one for each column), where q is the number of
##         covariates in the model. They must be non-negative
##  output:
##     out = information matrix
################################################################################

.scor_hess_outer_linpq <- function(b, N, TT, y, wy, p, Z) {

  ## scor
  lambdat <- as.vector( wy %*% b)
  a <- wy * ( as.vector(y[, -c(1:p)]) - lambdat ) / lambdat
  scor <- matrix( - Rfast::colsums(a), 2 * p + 1 + max( 0, ncol(Z) ), 1 )

  ## hess
  ct <- as.vector(y[, -(1:p)]) / lambdat^2
  hh <- crossprod( wy * ct, wy )

  ## outer
  #out1 <- 0
  k <- rep( 1:c(TT - p), each = N )
  b1 <- rowsum(a, k)
  #for (i in 1: c(TT - p) )  out1 <- out1 + tcrossprod(b1[i, ])
  out1 <- crossprod(b1)

  list(scor = scor, hh = hh, out = out1)
}

################################################################################
################################################################################
##  lin_estimnarpq() --- function for the constrained estimation of linear PNAR
##  model with p lags and q covariates. Inputs:
##    x0 = starting value of the optimization
##    N = number of nodes on the network
##    TT = temporal sample size
##    y = NxTT multivariate count time series
##    W = NxN row-normalized weighted adjacency matrix describing the network
##    p = number of lags in the model
##    Z = Nxq matrix of covariates (one for each column), where q is the number of
##        covariates in the model. They must be non-negative
##  output:
##    coefs = estimated QMLE coefficients
##    selin = standard errors estimates
##    tlin = t test estimates
##    score = value of the score at the optimization point
##    aic_lin = Akaike information criterion (AIC)
##    bic_lin = Bayesian information criterion (BIC)
##    qic_lin = Quasi information criterion (QIC)
################################################################################

lin_estimnarpq <- function(y, W, p, Z = NULL, uncons = FALSE, init = NULL, xtol_rel = 1e-8, maxeval = 100) {

  if ( min(W) < 0 ) {
    stop('The adjacency matrix W contains negative values.')
  }

  if ( !is.null(Z) ) {
    if ( min(Z) < 0 ) {
      stop('The matrix of covariates Z contains negative values.')
    }
    Z <- model.matrix(~., as.data.frame(Z))
    Z <- Z[1:dim(y)[2], -1, drop = FALSE]
  }

  y <- t(y)
  W <- W / Rfast::rowsums(W)
  W[ is.na(W) ] <- 0

  dm <- dim(y)   ;    N <- dm[1]    ;    TT <- dm[2]
  z <- W %*% y
  wy <- NULL
  for ( ti in (p + 1):TT )  wy <- rbind( wy, cbind(z[, (ti - 1):(ti - p)], y[, (ti - 1):(ti - p)], Z) )
  wy <- cbind(1, wy)

  if ( is.null(init) ) {

    XX <- crossprod(wy)
    Xy <- Rfast::eachcol.apply(wy, as.vector( y[, -c(1:p)] ) )
    x0 <- solve(XX, Xy)
    x0[x0 < 0] <- 0.001
  } else  x0 <- init

  m <- length(x0)
  # Lower and upper bounds (positivity constraints)
  lb <- rep(0, m)
  ub <- rep(Inf, m)

  # algorithm and relative tolerance
  opts <- list( "algorithm" = "NLOPT_LD_SLSQP", "xtol_rel" = xtol_rel, "maxeval" = maxeval )

  if ( uncons ) {

    s_qmle <- nloptr::nloptr(x0 = x0, eval_f = .logl_linpq, eval_grad_f = .scor_linpq, lb = lb,
                     ub = ub, opts = opts, N = N, TT = TT, y = y, W = W, wy = wy, p = p, Z = Z)
  } else {
    # Inequality constraints (parameters searched in the stationary region)
    # b are the parameters to be constrained
    constr <- function(b, N, TT, y, W, wy, p, Z) {
      con <- sum( b[2:(2 * p + 1)] ) - 1
      return(con)
    }
    # Jacobian of constraints
    # b are the parameters to be constrained
    j_constr <- function(b, N, TT, y, W, wy, p, Z) {
      j_con <- rep(1, m)
      j_con[1] <- 0
      return(j_con)
    }

    s_qmle <- nloptr::nloptr(x0 = x0, eval_f = .logl_linpq, eval_grad_f = .scor_linpq,
                      lb = lb, ub = ub, eval_g_ineq = constr, eval_jac_g_ineq = j_constr,
                      opts = opts, N = N, TT = TT, y = y, W = W, wy = wy, p = p, Z = Z)
  }

  coeflin <- s_qmle$solution

  ola <- .scor_hess_outer_linpq(coeflin, N, TT, y, wy, p, Z)
  S_lins <- ola$scor
  H_lins <- ola$hh
  G_lins <- ola$out
  solveH_lins <- solve(H_lins)
  V_lins <- solveH_lins %*% G_lins %*% solveH_lins
  SE_lins <- sqrt( diag(V_lins) )

  tlin <- coeflin/SE_lins
  pval <- 2 * pnorm(abs(tlin), lower.tail = FALSE)

  loglik <-  - s_qmle$objective
  aic_lins <- 2 * m + 2 * s_qmle$objective
  bic_lins <- log(TT) * m + 2 * s_qmle$objective
  qic_lins <- 2 * sum( H_lins * V_lins ) + 2 * s_qmle$objective

  coeflin <- cbind(coeflin, SE_lins, tlin, pval)
  colnames(coeflin) <- c("Estimate", "Std. Error", "z value", "Pr(>|z|)")
  coeflin <- as.data.frame(coeflin)
  a <- pval
  a[ which(pval > 0.1) ]   <- c("   ")
  a[ which(pval < 0.1) ]   <- c(".  ")
  a[ which(pval < 0.05) ]  <- c("*  ")
  a[ which(pval < 0.01) ]  <- c("** ")
  a[ which(pval < 0.001) ] <- c("***")
  coeflin <- cbind(coeflin, a)
  colnames(coeflin)[5] <- ""

  if ( !is.null( dim(Z) ) ) {
    rownames(coeflin) <- rownames(S_lins) <-  c( "beta0", paste("beta1", 1:p, sep =""), paste("beta2", 1:p, sep =""),
                                                 paste("delta", 1:dim(Z)[2], sep = "") )
  } else  rownames(coeflin) <- rownames(S_lins) <- c( "beta0", paste("beta1", 1:p, sep =""), paste("beta2", 1:p, sep ="") )
  ic <- c(aic_lins, bic_lins, qic_lins)
  names(ic) <- c("AIC", "BIC", "QIC")

 # if ( !uncons ) {
 #   if ( any( abs(S_lins) > 1e-3 ) )  {
 #     warning( paste("Optimization failed in the stationary region. Please try estimation without stationarity constraints.") )
 #   }
 # }

 # if ( uncons ) {
 #   if ( any( abs(S_lins) > 1e-3 ) )  {
 #     warning( paste("The score function is not close to zero.") )
 #   }
 # }

  result <- list( coefs = coeflin, score = S_lins, loglik = loglik, ic = ic )
  class(result) <- "PNAR"
  return(result)
}


