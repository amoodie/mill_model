## Scripts
Scripts written to manipulate these functions (i.e., to make a model) should be prefixed with `script_`.

#### `script_1paramset.m`
Is the simplest case where one grain size _distribution_ is suspended into a mill with one parameter set.
Calculated for both the DS and Rouse case and compared.


#### `script_simple_suspension.m`
This is a simple Rouse model.

#### `script_stratify.m`
This is a direct reimplementation of the parker ebook RTe-bookSuspSedDensityStrat in Matlab.
This code solves for the DS adjusted profile for one grain class.
The profiles are plotted at the end of the calculation (against the "no stratificaion" case).


## Functions
Functions may have any namespace, but try to make it descriptive and self-similar for functions serving a similar purpose.

#### `denstrat_1class.m`


#### `entr_WP04.m`


#### `find_Dxx.m`


#### `load_grainsize.m`


#### `makeDistToData.m`


#### `normalize_model.m`


#### `rouse_1class.m`


#### `rouse.m`


