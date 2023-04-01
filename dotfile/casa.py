#!/usr/bin/env python3

"""
Startup configuration for casa with AstroUtils
"""

# pylint: disable=all

from sys.path import append as path_append
from logging import getLogger, DEBUG

import numpy as np  # pylint: disable=unused-import
from numpy import log2

from astropy.io import fits
import casatools as ct

path_append("/home/mtourneb/Casa/analysis_scripts")
import analysisUtils as aU

logger = getLogger(__name__)
logger.setLevel(DEBUG)

es = aU.stuffForScienceDataReduction()

print('\nHi Tinmarino!\n')


def get_pixel_scale(frequency=100e9, distance=1000):
    """ Print pixel scale and image size
    Arg1: center frequency in Hz
    Arg2: distance in meter of the target baseline
    spr = 180 * 3600 / 3.1416  # Second Per Radian => the famous 206264
    c = 300e6  # Light speed in m/s
    """
    # Hi
    print(f'Calculating imagesize for {frequency}Hz on a {distance}m baseline')

    # 1/ Get wavelength => λ
    # -- the inverse of the frequency considering c=1 (i.e. scaled by c)
    l = 300e6 / frequency   # In meter => 0.0012

    # 2/ Get Pixel size => λ/D * 206264 => θ
    t = l / distance * 206264  # Resolution in arcsec (t like teta) => 0.4
    spp = t / 5  # Second Per Pixel, we want 5 pixel per PSF => 0.08 arcsec / pixel

    # 3/ Get Field Of View
    fov = l / 12 * 206264  # Field OF View: 21 arcsec
    npix = 1.5 * fov / spp  # Number of Pixel to get an image 1.5 x Field of View (=> safe border) => 390
    npix = 2 ** int(log2(npix)+1)  # Get the upper power of two  => 512

    # Bye
    dic = {
        'second_per_pixel': spp,
        'number_of_pixel': npix,
    }
    print(dic)
    return dic


def read_fits_array(image):
    # Load image
    fits_in = fits.open(image)

    # Get array
    return fits_in[0].data[0]


def write_fits_array(array, image):
    hdu = fits.PrimaryHDU(array)
    fits_out = fits.HDUList(hdu)
    fits_out.writeto(image)


def squash_cube(image='', start=0, end=-1, step=1):
    """ Squash many frames of a cube fits image
    """

    # Load image
    a_in = read_fits_array(image)

    # Declare output array copying the structure but in 2D
    a_out = a_in[0] * 0

    # Add frames to a_out
    for frame in a_in[start:end:step]:
        a_out += frame

    # Write out
    write_fits_array(a_out, image.strip('.fits') + f'_squashed_{start}_{end}.fits')


def bin_cube(image='', start=0, end=-1, step=1):
    """ Squash many frames of a cube fits image
    """
    # Get array
    a_in = read_fits_array(image)

    # Declare output array copying the structure but in 2D
    a_out = a_in[start:end:step] * 0

    # Add frames to a_out
    for i, frame in enumerate(a_in[start:end]):
        a_out[int(i / step)] += frame

    # Write out
    write_fits_array(a_out, image.strip('.fits') + f'_resized_{start}_{end}.fits')




def obs_get(remote_url):
    """ Download ASDM from ALMA archive Query
    Extract abd rename it
    """
    project_name = '2013.1.01161.S'
    uid = 'A002_Xa16f89_X2a8c'
    aq_prefix = 'https://almascience.nrao.edu/dataPortal'
    
    """
    wget https://almascience.nrao.edu/dataPortal/2013.1.01161.S_uid___A002_Xa16f89_X2a8c.asdm.sdm.tar
    tar xvf 2013.1.01161.S_uid___A002_Xa16f89_X2a8c.asdm.sdm.tar
    
    # TODO 
    mv uid___A002_Xa16f89_X2a8c.asdm.sdm uid___A002_Xa16f89_X2a8c
    """

    pass


def obs_inspect(vis='uid___A002_Xa16f89_X2a8c.ms.split.cal'):
    """ Execute the plotms required for what you need
    """
    # Filter
    field = 'NGC_4321'

    xaxis = 'frequency'
    yaxis = 'amp'
    selectdata = True
    coloraxis = 'baseline'
    showgui = True
    avgtime = '9999'

    # Tk Jano
    selectdata = True
    antenna = '0&1'
    intent = 'OBSERVE_TARGET#ON_SOURCE'
    iteraxis = 'spw'
    coloraxis = 'corr'
    gridrows = 3
    gridcols = 3


def obs_calibrate(inn='uid___A002_Xa16f89_X2a8c'):
    """ Calibrate ASDM folder in
    """
    # Instantiate method handler
    es = aU.stuffForScienceDataReduction()

    # Create reduction script from ASDM of vis folder name
    es.generateReducScript(inn)

    # Reduce (takes 1 minute per Gigabyte)
    execfile(inn + '.ms.scriptForCalibration.py' )


def obs_image(inn='', out='Test001', field='NGC1365'):
    """ Calibrated vis to fits image
    Using script from Dicks
    """


def obs_manual_image(inn='', out='Test001', field='NGC1365'):
    """ Calibrated vis to fits image
    """
    vis = 'uid___A002_Xa16f89_X2a8c.ms.split.cal'
    imagename = 'Test019'  # TODO out
    # Stop criterium and Iter factor
    niter = 10
    gain = 0.05
    threshold='0.01Jy'

    # Mask
    usemask = 'auto-multithresh'
    sidelobethreshold=0.5
    noisethreshold=3.0
    lownoisethreshold=2.0
    negativethreshold=0.0
    minbeamfrac=0.1
    growiterations=75
    dogrowprune=True
    minpercentchange=1.0
    fastnoise=False
    #usemask = 'user'
    #mask = 'bos [ ]'
    #sidelobethreshold = 2
    #noisethreshold = 4
    #lownoisethreshold = 1.5
    #minbeamfrac = 0.1
    #growiterations = 10
    #negativethreshold = 0.0
    #threshold = "2mJy"
    interactive = False
    # Filter
    field = 'NGC1365'  # Warning
    # Color

    specmode = 'cube'  # Or cube
    intent = 'OBSERVE_TARGET#ON_SOURCE'
    #start = '231.2GHz'
    #nchan = 1
    #width = '100MHz'
    # Total width = '272MHz'
    # Size
    #phasecenter = 'ICRS 03:33:36.380 -36.08.25.694'
    phasecenter='ICRS 03:33:36.3109 -036.08.25.214'
    gridder = 'mosaic'
    cell = ['1arcsec']
    imsize = [256, 256]
    # Constant
    interpolation = 'linear'
    outframe = 'LSRK'
    veltype = 'radio'
    strokes = 'I'
    datacolumn = 'corrected'
    restoringbeam = 'common'
    deconvolver = 'hogbom'
    weighting = 'briggs'
    robust = 0.5
    calcpsf = True
