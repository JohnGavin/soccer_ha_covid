library("rstan")
options(mc.cores=1)
# Simulating some data
n     = 100
y     = rnorm(n,1.6,0.2)

# Running stan code
model = stan_model("./brms/stan_em_1.stan")
# Error in sink(type = "output") : invalid connection

fit = sampling(model,list(n=n,y=y),iter=200,chains=4)

print(fit)

params = extract(fit)

par(mfrow=c(1,2))
ts.plot(params$mu,xlab="Iterations",ylab="mu")
hist(params$sigma,main="",xlab="sigma")
