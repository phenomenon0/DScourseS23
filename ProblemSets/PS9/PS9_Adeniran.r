# Load necessary packages
install.packages("nloptr")
install.packages("modelsummary")
library(nloptr)
library(modelsummary)
library(broom)

# Generate data
set.seed(100)
N <- 100000
K <- 10
X <- matrix(rnorm(N * (K - 1)), nrow = N, ncol = K - 1)
X <- cbind(1, X)
eps <- rnorm(N)

# Set the new true value of beta
true_beta <- c(1.5, -1, -0.25, 0.75, 3.5, -2, 0.5, 1, 1.25, 2)

# Generate y vector with the new true_beta
y <- X %*% true_beta + eps

# OLS closed-form solution
beta_hat_OLS <- solve(t(X) %*% X) %*% (t(X) %*% y)

# Gradient descent
iterations <- 1000
learning_rate <- 0.0000003
beta_hat_GD <- rep(0, K)

for (i in 1:iterations) {
  gradient <- -2/N * t(X) %*% (y - X %*% beta_hat_GD)
  beta_hat_GD <- beta_hat_GD - learning_rate * gradient
}

# Define the negative log-likelihood function
negative_log_likelihood <- function(theta) {
  N <- length(y)
  beta <- theta[1:(length(theta) - 1)]
  sigma <- theta[length(theta)]
  residuals <- y - X %*% beta
  log_likelihood <- -0.5 * N * log(2 * pi) - 0.5 * N * log(sigma^2) - sum(residuals^2) / (2 * sigma^2)
  return(-log_likelihood)
}

# Gradient function (provided)
gradient <- function(theta, Y, X) {
  grad <- as.vector(rep(0, length(theta)))
  beta <- theta[1:(length(theta) - 1)]
  sig <- theta[length(theta)]
  grad[1:(length(theta) - 1)] <- -t(X) %*% (Y - X %*% beta) / (sig^2)
  grad[length(theta)] <- dim(X)[1] / sig - crossprod(Y - X %*% beta) / (sig^3)
  return(grad)
}

# Create a wrapper function for the gradient to match nloptr's function signature
gradient_wrapper <- function(theta) {
  return(gradient(theta, y, X))
}

# Initialize theta with zeros and an initial guess for sigma
init_theta <- c(rep(0, K), 1)

# Compute beta_hat_MLE using L-BFGS algorithm
result_MLE <- nloptr(x0 = init_theta,
                     eval_f = negative_log_likelihood,
                     eval_grad_f = gradient_wrapper,
                     algorithm = "NLOPT_LD_LBFGS",
                     opts = list(ftol_rel = 1.0e-8))

theta_hat_MLE <- result_MLE$solution
beta_hat_MLE <- theta_hat_MLE[1:K]
sigma_hat_MLE <- theta_hat_MLE[length(theta_hat_MLE)]

# Compare the MLE estimate with the true value of beta
print("MLE estimate of beta:")
print(beta_hat_MLE)
print("MLE estimate of sigma:")
print(sigma_hat_MLE)


model_lm <- lm(y ~ X - 1)

# Create model summary
summary_lm <- modelsummary(model_lm)

# Save the model summary to a .tex file
modelsummary(summary_lm, output = "regression_summary.tex")


