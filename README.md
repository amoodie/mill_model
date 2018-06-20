# mill_model

simple models and scripts to explore the parameter space of spinner mills for entrainment experiments

## development

version 0.1 -- alpha, anything may change at any time.

Authors:
* Andrew J. Moodie

## files

### mill_model

This folder contains all the files used to run the mill model. 
Each file should contain an individual function.

Scripts written to manipulate these functions (i.e., to make a model) should be prefixed with `script_`.


### `stratify.m`
This is a direct reimplementation of the parker ebook RTe-bookSuspSedDensityStrat in Matlab.
Note that even this code relies on a settling velocity calculator defined in [`get_DSV.m` in another Matlab file located here.](https://github.com/amoodie/Matlab_programs/blob/master/get_DSV.m)

### `simple_suspension.m`
This is a simple Rouse model. All functions contained therein.
