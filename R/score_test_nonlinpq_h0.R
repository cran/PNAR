score_test_nonlinpq_h0 <- function(b, y, W, p, d, Z = NULL) {

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
  dimz <- ( !is.null(Z) ) * NCOL(Z)
  m <- 1 + 2 * p + max(0, dimz ) + 1
  b[m] <- 0

  z <- W %*% y
  zf <- log1p( z )
  f <-  -b[1] * zf
  x2 <- NULL
  wy <- NULL
  for ( ti in (p + 1):TT ) {
    wy <- rbind( wy, cbind(z[, (ti - 1):(ti - p)], y[, (ti - 1):(ti - p)], Z, f[, ti - d]) )
    x2 <- c(x2, zf[, ti - d]^2)
  }
  wy <- cbind(1, wy)
  lambdat <- as.vector( wy %*% b )

  ## scor
  a <- wy * ( as.vector( y[, -c(1:p)] ) - lambdat ) / lambdat
  S <- matrix( Rfast::colsums(a), m, 1 )

  ## hess
  Dt <- 1 / lambdat
  # ss1 <- wy * ( as.vector(y[, -c(1:p)]) - lambdat ) / lambdat
  ct <- as.vector( y[, -c(1:p)] ) / lambdat^2
  hh1 <- crossprod(wy * ct, wy)
  ss2a <- crossprod(x2 * Dt, as.vector(y[, -c(1:p)]) - lambdat ) * b[1]
  hh1[1, m] <- hh1[1, m] - S[m]/b[1]
  hh1[m, 1] <- hh1[1, m]
  hh1[m, m] <- hh1[m, m] - ss2a
  H <- hh1

  ## out
  # out1 <- 0
  k <- rep( 1:c(TT - p), each = N )
  b1 <- rowsum(a, k)
  # for ( i in 1: c(TT - p) )  out1 <- out1 + tcrossprod(b1[i, ])
  B <- crossprod(b1)

  solveHmm <- solve(H[-m, -m])
  Sigma <- B[m, m] - H[m, -m] %*% solveHmm %*% B[-m, m] -
           B[m, -m] %*% solveHmm %*% H[-m, m] +
           H[m, -m] %*% solveHmm %*% B[-m, -m] %*% solveHmm %*% H[-m, m]

  stat <- as.numeric(S[m])^2 / as.numeric(Sigma)
  pvalue <- pchisq(stat, 1, lower.tail = FALSE)

  statistic <- stat  ;   names(statistic) <- "chi-square-test statistic"
  parameter <- 1     ;   names(parameter) <- "df"
  p.value <- pvalue
  null.value <- 0
  names(null.value) <- "True gamma parameter is equal to 0"
  alternative <- "True gamma parameter is greater than 0"
  method <- "Linearity test against non-linear ID-PNAR(p) model"
  data.name <- c( "coefficients of the PNAR(p, q)/", "time series data/", "order/", "lag/", "covariates/" )
  result <- list( statistic = statistic, parameter = parameter, p.value = p.value,
                  alternative = alternative, method = method, data.name = data.name )
  class(result) <- "htest"
  return(result)
}



