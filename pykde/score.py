#!/usr/bin/python
import pickle
import numpy as np
import scipy.io as sio
import argparse
import pykde
import compare

def load_Ys(matfile):
    """
    matfile is path to .mat file containing:
        'Y' is a [n x p] array
        'Yhs' is a {k x 1} cell of [n x p] arrays
    """
    mat = sio.loadmat(matfile)
    Yhs = mat['Yhs']
    if len(Yhs) > 1:
        Yhs = Yhs.squeeze()
    else:
        Yhs = Yhs.flatten()
    return mat['Y'], Yhs

def write_scores(scores, outfile):
    if outfile is not None:
        sio.savemat(outfile, {'scores': np.array(scores)})

def load_and_score(matfile, outfile=None):
    """
    for each Yh in Yhs, fit kdes to Y and Yh
        then return L2 norm of the difference of the two kdes
    """
    Y, Yhs = load_Ys(matfile)
    scores = compare.kde_fit_and_score(Y, Yhs)
    write_scores(scores, outfile)
    return scores

def eval_all(matfile, outfile=None):
    """
    fit kde to Y
        then return probability of each Yh under that kde
    """
    Y, Yhs = load_Ys(matfile)
    kde_base, bandwidth = pykde.kde_fit_cv(Y)
    fnm = matfile.replace('.mat', '.pickle')
    pickle.dump(kde_base, open(fnm, "wb"))

    scorefcn = lambda ps: np.sum(np.log(ps))
    if len(Yhs.shape) == 1:
        scores = [scorefcn(pykde.kde_eval(kde_base, y)) for y in Yhs]
    else:
        scores = [[scorefcn(pykde.kde_eval(kde_base, y)) for y in Yh]\
            for Yh in Yhs]
    write_scores(scores, outfile)
    return scores

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('text', nargs="*")
    parser.add_argument('-f', "--infile", default=None, type=str, help="Journal directory.")
    parser.add_argument('-g', "--outfile", default=None, type=str, help="Journal directory.")
    args = parser.parse_args()
    if args.text == 'all':
        print load_and_score(args.infile, args.outfile)
    else:
        print eval_all(args.infile, args.outfile)
