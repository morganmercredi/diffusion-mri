# White Matter Microstructure Modeling with Oscillating Gradients

This repository houses MATLAB code used to analyze diffusion-weighted magnetic resonance images in Dr. Melanie Martin's lab at the University of Winnipeg.

## Image Analysis

There are three main parts to the program. 

 1. The first reads the MRI data and saves the scan parameters in a structure called ScanParameters.
 2. The second draws regions of interest on a set of registered images and  
    saves the voxel intensities in structures called ROIs and Noise.
 3. The third analyzes the regions of interest and outputs results in a structure called ROI. A structure called MicrostructureModel contains information on the particular model.

OGSEAllInOne.m will run all three steps in one program.

For example,
`ROI = OGSEAllInOne(scanner, exps, slice, startfilename, analysis_type);`

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
Each .mat files should contain an variable called *target_aligned*, which has a *NxN* array of the registered image. The image registration software in the *image_registration* folder will output the registered images in the right format. 

The function arguments are:

 - **scanner**: string specifying the scanner used to acquire the images (either "**UW**" (for University of Winnipeg) or "**Vanderbilt**".
  - **exps**: array of scans (e.g. [1 2 3 4 6 7 9])
  - **slice**: slice number (e.g. 1 or 2)
  -  **startfilename**: string with the beginning of the experiment name (e.g. "**brain_**")
  -  **analysis_type**: string specifying either "**ROI**" or  "**VBA**".  If **ROI** is used, voxel intensities in the region of interest will be averaged before analysis. If "**VBA**" is used, then each voxel in the region of interest will be analyzed individually.

A prompt will come up, choose the folder with the scan data (e.g. *brain_day2*).
A second prompt will come up, choose the folder with the registered images (e.g. *brain_registeredslice1*). Follow the prompts and draw ROIs and a noise ROI. Follow the prompts and choose a model.

Each part can also be run separately.
```
ScanParameters = GetScanData(scanner, datadirectory, exps, dir);
[ROIs, Noise] = GetROIsVoxels(manregdirectory, exps, startfilename, slice, ScanParameters, dir);
[ROI, MicrostructureModel] = OGSEVoxelAnalysis(analysis_type, ScanParameters, ROIs, Noise, dir);
```
In this case, **datadirectory** might be *MRI_data\brain_day2\\*, **manregdirectory** might be *Registered_images\brain_registeredslice1\\*, and **dir** is an existing folder for saving output.

The code relies on the MATLAB function [*lsqcurvefit*](https://www.mathworks.com/help/optim/ug/lsqcurvefit.html) for curve fitting. In fact, much of the work just involves loading MRI data and getting it into a form where it can work with *lsqcurvefit*. 

The simplest version takes an array of input data, an array of output data, a model function, and an initial guess for the parameters. The model function must have the form *modelfun(par, xdata)*, where *par* is a vector of model parameters and *xdata* is an array of input data. 

Since there might be multiple minima, the program uses a function called *RandomFits* to run *lsqcurvefit* many times with different initial guesses and to store all the results. The result with the smallest sum of squares is chosen at the end.

The signal models for a few microstructural geometries are located in *Analysis_scripts/signal_functions*. The geometries can also be combined into different forms. See *ModelSelection.m* for examples.

All quantities have units of millimeters, milliseconds, teslas or combinations of those.

## Output

Each structure output has a number of fields. Some of these names will change in the near future.

For example, ScanParameters has fields such as *GradientDuration* and *GradientSeparation*, which represent the gradient duration and separation (in ms). These are in *NxM* arrays, where *N* is the number of scans and *M* is the number of images per scan.

ROIs and Noise have information on voxel signal intensities and the region of interest. 
 - *Mask* is a binary image where voxels in the region of interest are set to 1 and those outside are zero. 
 - *MaskImage* is the MR image, but all voxels outside the region of interest are zero. 
 - Individual voxel signals are stored in *VoxelSignal*, which is an *NxMxK* array, where *N* is the number of scans, *M* is the number of images per scan, and *K* is the number of voxels in the region of interest. 
 - Voxel signal intensities averaged over the region of interest are stored in *MeanROISignal*, which is an *NxM* array, where *N* is the number of scans, *M* is the number of images per scan.
 - The standard deviation of voxel signal intensities over the region of interest are stored in *StDevROISignal*.
MicrostructureModel has fields describing the model used, such as the model function (*signal_model*), parameter names (*parameter_names*), units for the parameters (units) lower and upper bounds on the parameters (*lower_bound*, *upper_bound*), whether a parameter was fixed to some value beforehand (*fixed*). Since some parameters can be fixed beforehand, the names of free parameters can be found with *parameter_names(~fixed)* and the set values for fixed parameters will be *beta_initial(fixed)*. 

ROI has fields with the final estimated parameters. When using the **ROI** option, *roiParameters* stores the estimated parameters, where the elements correspond to the model parameters in *MicrostructureModel.parameter_names(~MicrostructureModel.fixed)*. Confidence intervals (95%) for each parameter are stored in *roiCI*. When using the **VBA** option, the array *voxelParameters* gives the estimated parameters for each voxel in the region of interest. Each column stores a different model parameter and the rows correspond to individual voxels. In the future, the structure ROI will probably be merged with MicrostructureModel.

## Citation

If you use this software, you must acknowledge the creators of this repository, link to this repository, and cite the following paper.

Mercredi, M., & Martin, M. (2018). Toward faster inference of micron-scale axon diameters using Monte Carlo simulations. Magnetic Resonance Materials in Physics, Biology and Medicine, 31, 511-530.

## Image Registration

This folder has a program to register diffusion MRI images.

*More information to come...*

