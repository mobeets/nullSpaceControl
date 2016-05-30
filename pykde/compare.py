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
    return [loss(ps, ps_true) for ps in Ps]

def kde_fit_and_score(Y, Yhs):
    """
    Y is [n x p]
    Yhs is list of [n x p]

    fits kdes for Y and Yhs
    returns scores of each kde from Yhs
        based on deviation from kde fit on Y
    """
    kde_base, bandwidth = pykde.kde_fit_cv(Y)
    kdes = [pykde.kde_fit(Yh, bandwidth) for Yh in Yhs]
    return score_all(kde_base, kdes, Y)
