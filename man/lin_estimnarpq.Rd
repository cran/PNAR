\name{Estimation of the linear Poisson NAR(p) model}
\alias{lin_estimnarpq}

\title{
Estimation of the linear Poisson NAR(p) model model with p lags and q
covariates (PNAR(p))
}

\description{
Estimation of the linear Poisson Network Autoregressive model of order \eqn{p}
with \eqn{q} covariates (PNAR(\eqn{p})).
}

\usage{
lin_estimnarpq(y, W, p, Z = NULL)
}

\arguments{
\item{y}{
An \eqn{N} x \eqn{TT} numerical matrix with the \eqn{N} multivariate
count time series over \eqn{TT} time periods.
}
\item{W}{
The \eqn{N} x \eqn{N} row-normalized non-negative adjacency matrix describing
the network. The main diagonal entries of the matrix should be zeros, all the
other entries should be non-negative and the maximum sum of elements over the
rows should equal one. The function row-normalizes the matrix if a non-normalized
adjacency matrix is provided.
}
\item{p}{
The number of lags in the model.
}
\item{Z}{
An \eqn{N} x \eqn{q} matrix of covariates (one for each column), where \eqn{q}
is the number of covariates in the model. Note that they must be non-negative.
}
}

\details{
This function performs a constrained estimation of the linear Poisson NAR(\eqn{p}) model with \eqn{q} non-negative valued covariates, for each node of the network \eqn{i=1,...,N} over the time sample \eqn{t=1,...,TT}, defined as
\deqn{
\lambda_{i,t}=\beta_{0}+\sum_{h=1}^{p}\beta_{1h}X_{i,t-h}+\beta_{2h}Y_{i,t-h}+\sum_{l=1}^{q}\delta_{l}Z_{i,l}
}
where \eqn{X_{i,t}=\sum_{j=1}^{N}W_{ij}Y_{j,t}} is the network effect, i.e. the weighted average impact of node \eqn{i} connections, with the weights of the mean being \eqn{W_{ij}}, the single element of the network matrix \eqn{W}. The sequence \eqn{\lambda_{i,t}} is the expecation of \eqn{Y_{i,t}} conditional to its past values. The parameter \eqn{\beta_{0}} is the intercept of the model, \eqn{\beta_{1h}} are the network coefficients, \eqn{\beta_{2h}} are the autoregressive parameters, and \eqn{\delta_{l}} are the coefficients assocciated to the covariates \eqn{Z_{i,l}}.

The estimation of the parameters of the model is performed by Quasi Maximum Likelihood Estimation (QMLE), maximizing the following quasi log-likelihood
\deqn{
l(\theta)=\sum_{t=1}^{TT}\sum_{i=1}^{N}\left[Y_{i,t}\log\lambda_{i,t}(\theta)-\lambda_{i,t}(\theta)\right]
}
with respect to the vector of unknown parameters \eqn{\theta} described above. The coefficients are defined only in the non-negative real line. The optimization is constrained in the stationary region where \eqn{\sum_{h=1}^{p}\beta_{1h}+\beta_{2h}<1}. The ordinary least squares estimates are employed as starting values of the optimization procedure.
Robust standard errors and t-tests are also returned.
}

\value{
A list including:
\item{coeflin}{
The vector of estimated QMLE coefficients.
}
\item{selin}{
The standard errors of the estimated coefficients.
}
\item{tlin}{
The t-test statistics of the estimated coefficients.
}
\item{score}{
The value of the quasi score function at the optimization point.
It should be close to 0 if the optimization is successful.
}
\item{loglik}{
The value of the maximized quasi log-likelihood.
}
\item{aic_lin}{
The Akaike information criterion (AIC).
}
\item{bic_lin}{
The Bayesian information criterion (BIC).
}
\item{qic_lin}{
The Quasi information criterion (QIC).
}
}

\references{
Armillotta, M. and K. Fokianos (2022). Poisson network autoregression.
\url{https://arxiv.org/abs/2104.06296}
}

\author{
Mirko Armillotta, Michail Tsagris and Konstantinos Fokianos.
}

\seealso{
\code{\link{log_lin_estimnarpq}
}
}

\examples{
W <- adja_gnp(20, 0.3)
y <- matrix(rpois(20 * 100, 10), ncol = 100)
mod <- lin_estimnarpq(y, W, p = 3)
}


