#!/usr/bin/python

from scipy import stats
import scipy.io
import numpy as np

from matplotlib import cm,colors
import matplotlib.pyplot as plt
# Lattice: bidimensional numpy array, example : lattice = ones((size, size), dtype=float )
# extent: axis extent for each axis  [begin_x,end_x,begin_y,end_y] 

print "Package Versions:"
import sklearn; print "  scikit-learn:", sklearn.__version__

from sklearn.neighbors import KernelDensity
from sklearn.grid_search import GridSearchCV

def plotcolormap(lattice,extent=None,fname = None):
    fig = plt.figure()    
    map1=colors.LinearSegmentedColormap.from_list('bla',['#000000','#FF0000','#FFFF00'])
    plt.imshow(lattice, map1,vmin = 0, interpolation='nearest',extent=extent)
    # vmin=0,vmax = 1,
    if fname is None:
        plt.show()
    else:
        plt.savefig(fname)

def main(num_dim,periodic_signal,bw,step,r_fname = 'training.mat',w_fname = "proba.mat"):
    num_dim = int(num_dim)
    periodic_signal = int(periodic_signal)
    bw = float(bw)
    step = float(step)

    mat = scipy.io.loadmat(r_fname)
    keyto_concat = ['X_training',
                'Y_training']
    to_concat = []
    for k in keyto_concat:
        print mat[k].shape
        to_concat.append(mat[k])
    to_concat[-1] = to_concat[-1][:,0:num_dim] # select coordinates of Y
    
    values = np.hstack(to_concat)
    print values.shape
    
    _,N = values.shape # number of dimensions
    print 'number of dimensions'
    print N
    mins = []
    maxs = []
    for i in xrange(N):
        min_tmp = values[:,i].min()
        max_tmp = values[:,i].max()
        delta = max_tmp - min_tmp
        max_tmp = max_tmp + delta / 10.
        min_tmp = min_tmp - delta / 10.
        mins.append(min_tmp)
        maxs.append(max_tmp)
    mins[0] = 0.
    maxs[0] = 1.

    print values

    # add the same values at X-1 and X+1 to make sure that the estiamted pdf is for a periodic signal
    if periodic_signal:
        Xp = values[:,0]+1
        Xm = values[:,0]-1
        Y = values[:,1:]
        
        to_concat = []
        to_concat.append(Xp)
        to_concat.append(Y)
        to_concat = np.column_stack(to_concat)
        to_concat2 = []
        to_concat2.append(to_concat)
        to_concat2.append(values)
        values = np.vstack(to_concat2)

        to_concat = []
        to_concat.append(Xm)
        to_concat.append(Y)
        to_concat = np.column_stack(to_concat)
        to_concat2 = []
        to_concat2.append(to_concat)
        to_concat2.append(values)
        values = np.vstack(to_concat2)

        print values.shape

    kde = KernelDensity(bandwidth=bw)
    kde.fit(values)

  
    # generate grid
    to_exec = ""
    to_exec += "np.mgrid["
    for i in np.arange(N):
        to_exec +="%f:%f:%fj," % (mins[i],maxs[i],step) # select number of samples in each dimension
    to_exec = to_exec[:-1]
    to_exec += "]"
    print to_exec

    meshes = eval(to_exec)
    print meshes.shape

    size_grid = meshes[0].shape
    print 'size_grid'
    print size_grid
    
    Z = np.vstack([X.reshape(1,X.size) for X in meshes]).transpose()
    print Z.shape


    # score_samples() returns the log-likelihood of the samples
    log_pdf = kde.score_samples(Z)
    probas = np.exp(log_pdf)

    print probas.shape
    probas = probas.transpose().reshape(size_grid)
    print probas.shape


    mdict = {'Proba_XY' : probas}
    i = 1
    for X in meshes:
        mdict['X_%d' % i] = X
        i+= 1
    print mdict.keys()
    scipy.io.savemat(w_fname,mdict)
    
    proba_plot = probas
    for i in np.arange(N-1, 1, -1):
        proba_plot = proba_plot.sum(i)
    plotcolormap(np.rot90(proba_plot),extent=[mins[0], maxs[0], mins[1], maxs[1]])

    
   
if __name__ == "__main__":
    import sys
    if len(sys.argv) <5:
        """
        print "Usage: "
	print "pdf_estimations.py <num_dim> <periodic_signal> <bw> <step>"
        print "pdf_estimations.py <num_dim> <periodic_signal> <bw> <step> <file_source.m>"
        print "pdf_estimations.py <num_dim> <periodic_signal> <bw> <step> <file_source.m> <file_target.m>"
        """
    elif len(sys.argv) == 5:
        main(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])
    elif len(sys.argv) == 6:
        main(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],r_fname = sys.argv[5])        
    elif len(sys.argv) == 7:
        main(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],r_fname = sys.argv[5],w_fname = sys.argv[6])

