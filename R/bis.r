#' Bayesian Iterated Screening (ultra-high, high or low dimensional).
#' @rdname bis
#' @description Perform Bayesian iterated screening in Gaussian regression models
#' @param X  An \eqn{n x p} matrix. Sparse matrices are supported and every
#' care is taken not to make copies of this (typically) giant matrix.
#' No need to center or scale.
#' @param y  The response vector of length \code{n}.
#' @param lam The slab precision parameter. Default: \code{n/p^2}.
#' @param w The prior inclusion probability of each variable. Default: \code{sqrt(n)/p}
#' as suggested by the theory of Wang et al. (2019).
#' @param criteria The stopping criteria. Could be "PP" for
#' posterior probability stopping rule, or "eBIC" for extended BIC stopping rule,
#' or "both" (default). Note that for "eBIC" the value of \code{w} is not used.
#'
#' @return A list with components
#' \item{model.pp}{An integer vector of screened model under posterior probability stopping rule.
#'  This will be null if only "eBIC" stopping criterion was used.}
#' \item{mdoel.ebic}{An integer vector of screened model under eBIC criterion. This will be NULL if
#'  only "PP" stopping criterion was used.}
#' \item{postprobs}{The sequence of posterior probabilities until the last included variable.
#'  This will be null if only "eBIC" stopping criterion was used. Here the last included variable
#'  is the last one included by either "PP" or "eBIC" if criteria="both" was selected}
#' \item{ebics}{The sequence of eBIC values until the last included variable.
#'  This will be null if only "PP" stopping criterion was used.  Here the last included variable
#'  is the last one included by either "PP" or "eBIC" if criteria="both" was selected}
#' @export

bis <- function(X,y,lam=nrow(X)/ncol(X)^2,criteria="n")
{
  p = ncol(X)
  n = nrow(X)
  ys = scale(y)
  
  xbar = colMeans(X)
  
  stopifnot(class(X) %in% c("dgCMatrix","matrix"))
  
  if(class(X) == "dgCMatrix") {
    D = 1/sqrt(colMSD_dgc(X,xbar))
  }  else   {
    D = apply(X,2,sd)
    D = 1/D
  }
  
  xty = D*as.numeric(crossprod(X,ys))
  
  
  yty <- n - 1
  xtx <- n - 1
  
  
  max.var = n; # Intially allocate for maximum of n variables.
  
  model = integer(n)
  postprob = numeric(max.var+1)
  
  
  
  R = matrix(NA,max.var,max.var)
  sumv02 = 0
  logdetR = 0;
  z = numeric(p)
  u   = numeric(p)
  v = numeric(max.var)
  
  
  postprob[1] = -0.5*(n-1)*log(n) # The posterior probability of the null model
  cat("\n Including: ")
  
  
  # First variable
  b0 = sqrt(xtx + lam)
  logdetR = log(R[1,1])
  logp <- 0.5*log(lam)-logdetR - 0.5*(n-1)*log(yty - (xty/b0)^2)

  j = which.max(logp)
  model[1] = j;
  postprob[2] = logp[j]
  
  # Need to do the second variable by hand
  if(max.var >= 2)
  {
    R[1,1] = b0;
    xjc = (X[,j] - xbar[j])*D[j]
    v[1] = xty[j]/R[1,1]
    sumv2 = v[1]^2
    
    S = D*crossprod(X,xjc)/R[1,1]
    z = S^2
    
    w = sqrt(xtx+lam - z)
    u = {Xty - v[1]*S}/w;
    
    RSS = yty - sumv2 - u^2
    RSS[j] = Inf
    logp = 0.5*log(lam) - logdetR - log(w) - 0.5*{n-1}*log(RSS)
    
    j = which.max(logp)
    model[2] = j
    postprob[3] = logp[j]
    
  }
  
  
  
  
  for(ii in 3:max.var)
  {

    model.cur = model[1:{ii-1}
    
    X1 = X[,model.cur],drop=FALSE]
    D1 = D[model.cur]
    Xbar1 = xbar[model.cur]
    xjc = (X[,j] - xbar[j])*D[j]
    
    a1 = backsolve(R,D1*crossprod(X1,xjc)
    
    X0txj = crossprod(X0 , xjc)
    temp1 = backsolve(chol.factor,X0txj,transpose = TRUE,k = ii-1L)
    temp2 = D[model.cur] * backsolve(chol.factor,temp1,k = ii-1L)
    temp3 = X0 %*% temp2 # the following is not needed as we are centering after two lines -sum(xbar[model.cur] * temp2)
    temp4 = xjc - temp3;
    temp4 = temp4 - mean(temp4)
    
    Xtz = D*crossprod(X,temp4)
    
    g = Xtz/chol.factor[ii-1,ii-1]
    sts = sts + g^2; 
    
    s1 = sqrt(xtx + lam - sts);
    
    sumv02 = sumv02 + u[j]^2
    logdetR = logdetR + log(chol.factor[ii-1,ii-1])
    u = {u*s0 - u[j]*g}/s1
    
    RSS = yty - sumv02 - u^2;
    RSS[model.cur] = Inf
    logp = -ii*loglam - logdetR - log(s0) - 0.5*(n-1)*log(RSS)
    
    j = which.max(logp)

    j = this$which.max
    
    postprob[ii] <- this$logp[j]
    model[ii] = j
    
    if(ii < max.var)
    {
      chol.factor[1:ii,ii] = ?
      chol.factor[ii,ii] = ?
      
     }
    
  }
  cat(" Done.\n")
  
  return(list(model.pp = model, postprobs=postprob[1:ii]))
}


































# bis <- function(X,y,lam=nrow(X)/ncol(X)^2,w = sqrt(nrow(X))/ncol(X),criteria="PP")
# {
#   p = ncol(X)
#   n = nrow(X)
#   ys = scale(y)
#   
#   xbar = colMeans(X)
#   
#   stopifnot(class(X) %in% c("dgCMatrix","matrix"))
#   
#   if(class(X) == "dgCMatrix") {
#     D = 1/sqrt(colMSD_dgc(X,xbar))
#   }  else   {
#     D = apply(X,2,sd)
#     D = 1/D
#   }
#   Xty = D*as.numeric(crossprod(X,ys))
#   
#   
#   max.var = n; # Intially allocate for maximum of n variables.
#   
#   model = integer(0L)
#   postprob = numeric(max.var+1)
#   R0 = NULL
#   v0 = NULL
#   
#   postprob[1] = -0.5*(n-1)*log(n) # The posterior probability of the null model
#   cat("\n Including: ")
#   for(ii in 1:n)
#   {
#     this <- addvar(model = model,x = X, ys = ys, xty = Xty, lam = lam, w = w,
#                    R0 = R0, v0 = v0,D = D,xbar = xbar)
#     j = this$which.max
#     if(this$logp[j] < postprob[ii])      break;
#     cat(j,", ",sep = "")
#     postprob[ii+1] <- this$logp[j]
#     model = c(model,j)
#     R0 = this$R
#     v0 = this$v
#   }
#   cat(" Done.\n")
#   
#   return(list(model.pp = model, postprobs=postprob[1:ii]))
# }
