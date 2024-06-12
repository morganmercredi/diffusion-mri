# White Matter Microstructure Modeling with Oscillating Gradients

This repository houses MATLAB code used to analyze diffusion-weighted magnetic resonance images in Dr. Melanie Martin's lab at the University of Winnipeg.

There are three main parts to the program. 

 1. The first reads the MRI data and saves the scan parameters in a structure called ScanParameters.
 2. The second draws regions of interest on a set of registered images and  
    saves the voxel intensities in structures called ROIs and Noise.
 3. The third analyzes the regions of interest and outputs results in a structure called ROI. A structure called MicrostructureModel contains information on the particular model.

OGSEAllInOne.m will run all three steps in one program.

For example,
`ROI = OGSEAllInOne(scanner, expnumstart, expnumstop, slice, startfilename, analysis_type);`

The program assumes that the file organization looks similar to the following.

```bash
+-- MRI_data
¦   +-- brain_day2
¦   ¦   +-- 1
¦   ¦   ¦   +--method
¦   ¦   ¦   +--[other files]
¦   ¦   +-- 2
¦   ¦   ¦   +--method
¦   ¦   ¦   +--[other files]
¦   ¦   +-- 3
¦   ¦   ¦   +--method
¦   ¦   ¦   +--[other files]
¦   ¦   +--[other files]
+-- Registered_images
¦   +-- brain_registeredslice1
¦   ¦   +-- brain_1_sl_1_1.mat
¦   ¦   +-- brain_1_sl_1_2.mat
¦   ¦   +-- brain_2_sl_1_1.mat
¦   ¦   +-- brain_2_sl_1_2.mat
¦   ¦   +-- brain_3_sl_1_1.mat
¦   ¦   +-- brain_3_sl_1_2.mat
¦   +-- brain_registeredslice2
¦   ¦   +-- brain_1_sl_2_1.mat
¦   ¦   +-- brain_1_sl_2_2.mat
¦   ¦   +-- brain_2_sl_2_1.mat
¦   ¦   +-- brain_2_sl_2_2.mat
¦   ¦   +-- brain_3_sl_2_1.mat
¦   ¦   +-- brain_3_sl_2_2.mat
```
The function arguments are:

 - **scanner**: string specifying the scanner used to acquire the images (either "**UW**" (for University of Winnipeg) or "**Vanderbilt**".
  - **expnumstart**: first scan number (e.g. 1)
  - **expnumstop**: final scan number (e.g. 3)
  - **slice**: slice number (e.g. 1 or 2)
  -  **startfilename**: string with the beginning of the experiment name (e.g. "**brain_**")
  -  **analysis_type**: string specifying either "**ROI**" or  "**VBA**".  If **ROI** is used, voxel intensities in the region of interest will be averaged before analysis. If "**VBA**" is used, then each voxel in the region of interest will be analyzed individually.

A prompt will come up, choose the folder with the scan data (e.g. *brain_day2*).
A second prompt will come up, choose the folder with the registered images (e.g. *brain_registeredslice1*). Follow the prompts and draw ROIs and a noise ROI. Follow the prompts and choose a model.

Each part can also be run separately.
```
ScanParameters = GetScanData(scanner, datadirectory, expnumstart, expnumstop, dir);
[ROIs, Noise] = GetROIsVoxels(manregdirectory, expnumstart, expnumstop, startfilename, slice, ScanParameters, dir);
[ROI, MicrostructureModel] = OGSEVoxelAnalysis(analysis_type, ScanParameters, ROIs, Noise, dir);
```
In this case, **datadirectory** might be *MRI_data\brain_day2\\*, **manregdirectory** might be *Registered_images\brain_registeredslice1\\*, and **dir** is an existing folder for saving output.

The code relies on the MATLAB function [*lsqcurvefit*](https://www.mathworks.com/help/optim/ug/lsqcurvefit.html) for curve fitting. In fact, much of the work just involves loading MRI data and getting it into a form where it can work with *lsqcurvefit*. 

The simplest version takes an array of input data, an array of output data, a model function, and an initial guess for the parameters. The model function must have the form *modelfun(par, xdata)*, where *par* is a vector of model parameters and *xdata* is an array of input data. 

Since there might be multiple minima, the program uses a function called *RandomFits* to run *lsqcurvefit* many times with different initial guesses and to store all the results. The result with the smallest sum of squares is chosen at the end.

The signal models for a few microstructural geometries are located in *Analysis_scripts/signal_functions*. The geometries can also be combined into different forms. See *ModelSelection.m* for examples.

All quantities have units of millimeters, milliseconds, teslas or combinations of those.

## Citation

If you use this software, you must acknowledge the creators of this repository, link to this repository, and cite the following paper.

Mercredi, M., & Martin, M. (2018). Toward faster inference of micron-scale axon diameters using Monte Carlo simulations. Magnetic Resonance Materials in Physics, Biology and Medicine, 31, 511-530.

