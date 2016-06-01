import numpy as np
import pykde

def loss(ps, psh):
    return np.linalg.norm(ps - psh)

def score_all(kde_true, kde_hs, grid):
    """
    evaluates kde_true on grid to get true probs
    returns error of each kde_hs's estimate of these probs
    """    
    ps_true = pykde.kde_eval(kde_true, grid)
    Ps = [pykde.kde_eval(kde_h, grid) for kde_h in kde_hs]
    return [loss(ps_true, ps) for ps in Ps]

def sample_unif_grid(Ys, n):
    return np.random.uniform(low=np.min(Ys,0), high=np.max(Ys,0),\
        size=[n,Ys.shape[1]])

def kde_fit_and_score(Y, Yhs, n=None):
    """
    Y is [n x p]
    Yhs is list of [n x p]

    fits kdes for Y and Yhs
    returns scores of each kde from Yhs
        based on deviation from kde fit on Y
    """
    n = n if n is not None else 50*Y.shape[0]

    # fit kdes
    kde_base, bandwidth = pykde.kde_fit_cv(Y)
    # kdes = [pykde.kde_fit(Yh, bandwidth) for Yh in Yhs]
    kdes = [pykde.kde_fit_cv(Yh) for Yh in Yhs]
    # print bandwidth, [kde[1] for kde in kdes]
    kdes = [kde[0] for kde in kdes]

    # opt1: eval on random grid sampled within bounds of all points
    # grid = sample_unif_grid(np.vstack([np.vstack(Yhs), Y]), n)
    
    # opt2: eval on Y
    # grid = Y
    
    # opt3: eval on random sample from kde_base
    grid = kde_base.sample(n)

    return score_all(kde_base, kdes, grid)
