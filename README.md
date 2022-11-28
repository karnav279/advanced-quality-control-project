# advanced-quality-control-project

The project is based on a set of data collected from a manufacturing process in which, both in-control and out-of-control
data are present. Given dataset has 209 process parameters and 552 observations of each parameter with
sample size (n) = 1. It is assumed that the given data sample comes from a multivariate normal distribution with unknown population
mean and covariances. Monitoring such a big number of parameters is infeasible because of “Curse of
dimensionality”. So, it is needed to reduce the dimensions (or parameters) to be monitored using dimensional reduction
technique called Principal Component Analysis (PCA). Hence, PCA was performed on 209 parameters using
correlation and covariance matrix. The correlation matrix did not represent enough data with a smaller number of
Principal Components (PC) but the Covariance matrix captured 78.1% of variance explained in the first three PCs.

Moving forward with the first three PCs, a Phase-I analysis was performed to set up control charts, identify out-of-control
points, remove the points, and achieve in-control process. The control charts used to monitor the PCs in this
project are T2 chart, multiple univariate x̄ charts and multivariate CUSUM chart. These specific charts were
considered as the T2 chart is proficient in detecting spike type signals and the multivariate CUSUM can detect small
jumps (mean shifts) in data. Individual x̄ charts help visualize data in different directions. Considering x̄ charts each
PC is uncorrelated with each other and hence any point is considered to be out-of-control if it signals in any chart.
To accommodate for this inflation in variance, confidence interval for the x̄ chart is approximately one-third of the
3-sigma control limit (α = 0.0009). x̄ chart for 2nd PC showed a small mean shift in the initial observations, which
was confirmed by the multivariate CUSUM chart. Hence, the first 36 points had to be eliminated to remove the
initial mean shift.

The T2 chart indicates multiple out control points in the form of spikes. These must be iteratively removed as a part
of Phase-I analysis. It took a total of 6 iterations to remove all out-of-control data points based on the T2 chart. By
the end of 6th iteration, for 3 Principal Components 72 out-of-control data points were removed from the original
552 data points and hence finally the result was 480 in-control data points in the T2 chart. Sanity check was
performed for these remaining 480 observations using m-CUSUM chart and individual x̄ chart, and these charts
combined with the results of T2 chart. Hence the in-control process can be established after removing the suggested
points. After the in-control process has been established the final in-control mean and covariance matrices were
calculated.
