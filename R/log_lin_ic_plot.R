log_lin_ic_plot <- function(y, W, p = 1:10, Z = NULL, uncons = FALSE, ic = "QIC") {

  criterion <- ic

  if ( min(W) < 0 ) {
    stop('The adjacency matrix W contains negative values.')
  }

  if ( !is.null(Z) ) {
    Z <- model.matrix( ~., as.data.frame(Z) )
    Z <- Z[1:dim(y)[2], -1, drop = FALSE]
  }

  y <- t(y)
  W <- W / Rfast::rowsums(W)
  W[ is.na(W) ] <- 0

  dm <- dim(y)   ;    N <- dm[1]    ;    TT <- dm[2]
  ly <- log1p(y)
  z <- W %*% ly

  ic <- matrix(nrow = length(p), ncol = 3)

  for ( i in 1:length(p) ) {

  wy <- NULL
  for ( ti in (p[i] + 1):TT )  wy <- rbind( wy, cbind(z[, (ti - 1):(ti - p[i])], ly[, (ti - 1):(ti - p[i])], Z) )
  wy <- cbind(1, wy)

  XX <- crossprod(wy)
  Xy <- Rfast::eachcol.apply(wy, as.vector( ly[, -c(1:p[i])] ) )
  x0 <- solve(XX, Xy)

  m <- length(x0)
  # algorithm and and relative tolerance
  opts <- list("algorithm" = "NLOPT_LD_SLSQP", "xtol_rel" = 1e-8)

  if( uncons ) {
    s_qmle <- nloptr::nloptr(x0 = x0, eval_f = .logl_log_linpq, eval_grad_f = .scor_logpq,
                             opts = opts, N = N, TT = TT, y = y, W = W, wy = wy, p = p[i], Z = Z)
  } else {

    # Inequality constraints (parameters searched in the stationary region)
    # b are the parameters to be constrained
    constr <- function(b, N, TT, y, W, wy, p, Z) {
      con <- sum( abs( b[2:(2 * p + 1)] ) ) - 1
      return(con)
    }

    # Jacobian of constraints
    # b are the parameters to be constrained
    j_constr <- function(b, N, TT, y, W, wy, p, Z) {
      j_con <- b/abs(b)
      j_con[1] <- 0
      return(j_con)
    }

    s_qmle <- nloptr::nloptr(x0 = x0, eval_f = .logl_log_linpq, eval_grad_f = .scor_logpq,
                             eval_g_ineq = constr, eval_jac_g_ineq = j_constr, opts = opts,
                             N = N, TT = TT, y = y, W = W, wy = wy, p = p[i], Z = Z)
  }

  coeflin <- s_qmle$solution

  ola <- .scor_hess_outer_logpq(coeflin, N, TT, y, wy, p[i], Z)
  S_lins <- ola$scor
  H_lins <- ola$hh
  G_lins <- ola$out

  solveH_lins <- solve(H_lins)
  V_lins <- solveH_lins %*% G_lins %*% solveH_lins

  ic[i, 1] <- 2 * m + 2 * s_qmle$objective
  ic[i, 2] <- log(TT) * m + 2 * s_qmle$objective
  ic[i, 3] <- 2 * sum(H_lins * V_lins ) + 2 * s_qmle$objective

  }

  if ( criterion == "AIC" ) {

  plot(p, ic[, 1], type = "b", xlab = "Lag", ylab = "AIC", cex.lab = 1.3, cex.axis = 1.3, xaxt = "n")
  abline(v = p, col = "lightgrey", lty = 2)
  abline(h = seq(min(ic[, 1]), max(ic[, 1]), length.out = length(p) ), lty = 2, col = "lightgrey")
  points(p, ic[, 1], pch = 16, col = "blue")
  mtext(text = p, side = 1, at = p, las = 1, font = 2, line = 0.7 )

  ic <- ic[, 1]
  names(ic) <- paste("Lag=", p, sep = "")

  } else if ( criterion == "BIC" ) {

  plot(p, ic[, 2], type = "b", xlab = "Lag", ylab = "BIC", cex.lab = 1.3, cex.axis = 1.3, xaxt = "n")
  abline(v = p, col = "lightgrey", lty = 2)
  abline(h = seq(min(ic[, 2]), max(ic[, 2]), length.out = length(p) ), lty = 2, col = "lightgrey")
  points(p, ic[, 2], pch = 16, col = "blue")
  mtext(text = p, side = 1, at = p, las = 1, font = 2, line = 0.7 )

  ic <- ic[, 2]
  names(ic) <- paste("Lag=", p, sep = "")

  } else if ( criterion == "QIC" ) {

  plot(p, ic[, 3], type = "b", xlab = "Lag", ylab = "QIC", cex.lab = 1.3, cex.axis = 1.3, xaxt = "n")
  abline(v = p, col = "lightgrey", lty = 2)
  abline(h = seq(min(ic[, 3]), max(ic[, 3]), length.out = length(p) ), lty = 2, col = "lightgrey")
  points(p, ic[, 3], pch = 16, col = "blue")
  mtext(text = p, side = 1, at = p, las = 1, font = 2, line = 0.7 )

  ic <- ic[, 3]
  names(ic) <- paste("Lag=", p, sep = "")

  }

  ic
}


