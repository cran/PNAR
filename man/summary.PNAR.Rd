\name{summary.PNAR}
\alias{summary.PNAR}
\alias{print.summary.PNAR}
\alias{print.PNAR}

\title{S3 methods for extracting the results of the estimation functions
}

\description{
S3 methods for extracting the results of the estimation functions.
}

\usage{
\method{summary}{PNAR}(object, ...)
\method{print}{summary.PNAR}(x, ...)
\method{print}{PNAR}(x, ...)
}

\arguments{
\item{object}{
An object containing the results of the estimation function \code{\link{lin_estimnarpq}} or \code{\link{log_lin_estimnarpq}}.
}
\item{x}{
An object containing the results of the estimation function \code{\link{lin_estimnarpq}} or \code{\link{log_lin_estimnarpq}}.
}
\item{...}{
Extra arguments the user can pass.
}
}

\details{
These functions print the output of the estimation functions.
}

\value{
The print.PNAR() function prints the coefficients of the model.
The summary.PNAR() function prints the output in the lm() style.
}

\references{
Armillotta, M. and K. Fokianos (2022a). Poisson network autoregression.
\url{https://arxiv.org/abs/2104.06296}

Armillotta, M., Tsagris, M. and Fokianos, K. (2022c). The R-package PNAR
for modelling count network time series.
\url{https://arxiv.org/abs/2211.02582}
}

\author{
Mirko Armillotta, Michail Tsagris and Konstantinos Fokianos.
}

\seealso{
\code{\link{log_lin_estimnarpq}
}
}

\examples{
data(crime)
data(crime_W)
mod1 <- lin_estimnarpq(crime, crime_W, p = 2)
mod1
print(mod1)
summary(mod1)
}


