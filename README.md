# mill_model

simple models and scripts to explore the parameter space of spinner mills for entrainment experiments

## development

version 0.1 -- alpha, anything may change at any time.

Authors:
* Andrew J. Moodie

Note that this code relies on a settling velocity calculator defined in [`get_DSV.m` in another Matlab file located here.](https://github.com/amoodie/Matlab_programs/blob/master/get_DSV.m)

## files

### mill_model

This folder contains all the files used to run the mill model. 
Each file should contain an individual function.

Scripts written to manipulate these functions (i.e., to make a model) should be prefixed with `script_`.

* `script_1paramset.m` is the simplest case where one grain size _distribution_ is suspended into a mill with one parameter set.

Functions may have any namespace, but try to make it descriptive and self-similar for functions serving a similar purpose.

* `denstrat_1class.m` is a function to calculate the density stratified profile for one grain size class. Requires inputs.


### `stratify.m`
This is a direct reimplementation of the parker ebook RTe-bookSuspSedDensityStrat in Matlab.
This code solves for the DS adjusted profile for one grain class.
The profiles are plotted at the end of the calculation (against the "no stratificaion" case).


### `simple_suspension.m`
This is a simple Rouse model. 

