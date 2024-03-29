\name{rcopula}
\alias{rcopula}

\title{
Random number generation of copula functions
}

\description{
Random number generation of copula functions.
}

\usage{
rcopula(n, N, copula = "gaussian", corrtype = "equicorrelation",
rho, dof = 1, cholR = NULL)
}

\arguments{
\item{n}{
The number of random values to generate.
}
\item{N}{
The number of variables for which random valeus will be generated.
}
\item{copula}{
Which copula function to use? The "gaussian", "t", or "clayton".
}
\item{rho}{
The the value of the copula parameter (\eqn{\rho}).
A scalar in \eqn{[-1,1]} for elliptical copulas (Gaussian, t), a value
greater than or equal to -1 for Clayton copula.
}
\item{corrtype}{
Used only for elliptical copulas. The type of correlation matrix employed for
the copula; it will either be the "equicorrelation" or "toeplitz". The
"equicorrelation" option generates a correlation matrix where all the off-diagonal
entries equal \eqn{\rho}. The "toeplitz" option generates a correlation matrix
whose generic off-diagonal \eqn{(i,j)}-element is \eqn{\rho^{|i-j|}}.
}
\item{dof}{
The degrees of freedom for Student's t copula.
}
\item{cholR}{
An alternative input for elliptic copulas, providing directly the Cholesky
decomposition for a specific correlation matrix to be passed, otherwise leave
it NULL.
}
}

\details{
This function generates random copula values from Gaussian, Student's t, or
Clayton copulas based on a single copula paremeter and different correlation
structures.
}

\value{
An \eqn{n \times N} matrix with the simulated copula values.
}

\references{
Nelsen, Roger B. (1999). \emph{An Introduction to Copulas}, Springer.
}

\author{
Mirko Armillotta, Michail Tsagris and Konstantinos Fokianos.
}

\seealso{
\code{\link{getN}, \link{poisson.MODpq}, \link{poisson.MODpq.log}
}
}

\examples{
u <- rcopula(n = 100, N = 50, rho = 0.3)
}


