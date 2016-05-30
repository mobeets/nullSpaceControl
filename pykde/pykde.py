import numpy as np
import matplotlib.pyplot as plt
from sklearn.grid_search import GridSearchCV
from sklearn.neighbors.kde import KernelDensity
from scipy.stats.distributions import norm

def kde_fit_cv(x, bs=None, cv=10):
    """
    x is [n x p]
    bs is [k x 1] list of bootstrap values to compare
    cv is int, the number of folds to cross-validate
    """
    if bs is None:
        bs = np.linspace(0.1, 1.0, 30)
    grid = GridSearchCV(KernelDensity(), {'bandwidth': bs}, cv=cv)
    grid.fit(x)
    # print grid.best_params_
    return grid.best_estimator_, grid.best_params_['bandwidth']

def kde_fit(x, bandwidth):
    kde = KernelDensity(bandwidth=bandwidth).fit(x)
    return kde

def kde_eval(kde, grid):
    """
    kde is sklearn.neighbors.kde.KernelDensity
    grid is [n x p]
    """
    return np.exp(kde.score_samples(grid))

def make_xy_grid(xmin, xmax, nbins):
    """
    returns an [n x 2] grid of x,y points
        where x and y are linearly spaced between xmin and xmax
    """
    x_grid = np.linspace(xmin, xmax, nbins)
    xv, yv = np.meshgrid(x_grid, x_grid)
    return np.vstack([xv.flatten(), yv.flatten()]).T

def plot(xv, yv, pdf):
    return plt.contourf(xv, yv, pdf.reshape(xv.shape))

def example():
    xy_grid = make_xy_grid(-4.5, 3.5, 100)
    x = np.concatenate([norm(-1, 1.).rvs(400),
                        norm(1, 0.3).rvs(100)])
    x = x.reshape([250, 2])
    kde, bandwidth = kde_fit_cv(x)
    pdf = kde_eval(kde, xy_grid)
    plot(xv, yv, pdf)

if __name__ == '__main__':
    example()
