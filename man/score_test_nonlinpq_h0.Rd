\name{Linearity test against non-linear ID-PNAR(p) model}
\alias{score_test_nonlinpq_h0}

\title{
Linearity test against non-linear ID-PNAR(p) model
}

\description{
Quasi score test for testing linearity of Poisson Network Autoregressive model
of order \eqn{p} against the non-linear Intercep Drift (ID) version
(ID-PNAR(\eqn{p})).
}

\usage{
score_test_nonlinpq_h0(b, y, W, p, d, Z = NULL)
}

\arguments{
\item{b}{
The estimated parameters from the linear PNAR model, in the following order:
(intercept, network parameters, autoregressive parameters, covariates).
The dimension of the vector should be 2\code{p} + 1 + number of covariates.
}
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
\item{d}{
The lag parameter of non-linear variable (should be between 1 and p).
}
\item{Z}{
An \eqn{N} x \eqn{q} matrix of covariates (one for each column),
where \eqn{q} is the number of covariates in the model.
Note that they must be non-negative.
}
}

\details{
The function computes the quasi score test for testing linearity of Poisson Network Autoregressive model
of order \eqn{p} against the following ID-PNAR(\eqn{p}) model. For each node of the network \eqn{i=1,...,N}
over the time sample \eqn{t=1,...,TT}
\deqn{
\lambda_{i,t}=\frac{\beta_{0}}{(1+X_{i,t-d})^{\gamma}}+\sum_{h=1}^{p}\beta_{1h}X_{i,t-h}+\beta_{2h}Y_{i,t-h}+\sum_{l=1}^{q}\delta_{l}Z_{i,l}
}
where \eqn{X_{i,t}=\sum_{j=1}^{N}W_{ij}Y_{j,t}} is the network effect, i.e. the weighted average impact of node
\eqn{i} connections, with the weights of the mean being \eqn{W_{ij}}, the single element of the network matrix \eqn{W}.
The sequence \eqn{\lambda_{t}} is the expectation of \eqn{Y_{t}} conditional to its past values.

The null hypothesis of the test is defined as \eqn{H_{0}: \gamma=0}, versus the alternative \eqn{H_{1}: \gamma >0}.
The test statistic has the form
\deqn{
LM=S^{'}(\hat{\theta})\Sigma^{-1}(\hat{\theta})S(\hat{\theta})
}
where
\deqn{
S(\hat{\theta})=\sum_{t=1}^{TT}\sum_{i=1}^{N}\left(\frac{Y_{i,t}}{\lambda_{i,t}(\hat{\theta})}-1\right)\frac{\partial\lambda_{i,t}(\hat{\theta})}{\partial\gamma}
}
is the partition of the quasi score related to the non-linear parameter \eqn{\gamma}, evaluated at the estimated
parameters \eqn{\hat{\theta}} under the null assumption \eqn{H_{0}} (linear model), and \eqn{\Sigma(\hat{\theta})} is
the variance of \eqn{S(\hat{\theta})}. Under \eqn{H_{0}}, the test asymptotically follows a chi-square with 1 degree of freedom. For details see Armillotta and Fokianos (2022b, Sec. 4).
}


\value{
A list including:
\item{stat}{
The value of the chi-square test statistic.
}
\item{pvalue}{
The p-value of the chi-square test statistic.
}
}

\references{
Armillotta, M. and K. Fokianos (2022a). Poisson network autoregression.
\url{https://arxiv.org/abs/2104.06296}

Armillotta, M. and K. Fokianos (2022b). Testing linearity for network
autoregressive models.
\url{https://arxiv.org/abs/2202.03852}
}

\author{
Mirko Armillotta, Michail Tsagris and Konstantinos Fokianos.
}

\seealso{
\code{\link{score_test_stnarpq_j}, \link{score_test_tnarpq_j},
\link{lin_estimnarpq}
}
}

\examples{
data(crime)
data(crime_W)
mod1 <- lin_estimnarpq(crime, crime_W, p = 2)
ca <- mod1$coeflin
score_test_nonlinpq_h0(ca, crime, crime_W, p = 2, d = 1)
}


