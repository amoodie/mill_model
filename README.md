# mill_model

simple models and scripts to explore the parameter space of spinner mills for entrainment experiments

## development

version 0.1 -- alpha, anything may change at any time.

Authors:
* Andrew J. Moodie

Note that this code relies on a settling velocity calculator defined in [`get_DSV.m` in another Matlab file located here.](https://github.com/amoodie/Matlab_programs/blob/master/get_DSV.m)

## documentation

### mill_model

This folder contains all the files used to run the mill model. 
Each file should contain an individual function or script.

See [`mill_model_docs.md`](mill_model_docs.md) for complete documentation.

### grainsize_distributions

This folder contains tab or comma separated value documents with grainsize distributions therein.
Use `load_grainsize(filepath)` to load a sheet for use in your script.
If you add a new distribution, add it to the [`grainsize_distributions_docs.md`](grainsize_distributions_docs.md) file with a complete description.



## todo list

- [ ] documentation for `find_Dxx`
- [ ] make `find_Dxx` robust to cumulative distribution inputs
- [ ] documentation for `entr_WP04`
- [ ] make `load_grainsize` flexible and robust (has a todo list inside)
- [ ] documentation for `makeDistToData` (and change name?)

