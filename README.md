***Page under development***

# write_mats.ado 
## Another solution to export stata tables into Latex

This repository contains not only ``write_mats.ado``, but also a few examples in stata and latex showing how I tipically use this utility. This utility is not a substitute for tools like estout/esttab, but I find it useful in my workflow and for whenever I need to create a non-standard table. 

For example, often we need to create a table when only one coefficient from a particular regression is of interest, and we want to combine estimated effects from multiple outcomes as rows and specifications as columns, such as this.

![alt text](https://github.com/alemartinello/write_mats/blob/master/images/table_multiple_specs.png "Table with multiple specifications")

Alternatively, we might want to add the results of tests in a specific a column, and selected coefficients from a dynamic specification in others like here

![alt text](https://github.com/alemartinello/write_mats/blob/master/images/table_with_test.PNG "Table with multiple specifications")

All these tables can be donw with standard stata tools, but they require some workarounds. I personally like to work with ``write_mats`` as it offers a few advantages

1. **Separating the estimation and table creation process:** Using this approach requires saving regression estimates on the disk as ``.ster`` files. Especially when working on large dataset, this has been a game-changer for me, as it allowed me to add coefficients or modify the layout of the table without having to re-run all your estimates.

2. **Structured workflow:** I personally dislike if code outputs also the ``\begin{tabular}`` part of the latex table, headings, and other unnecessary stuff. Some journals might require you to change it manually, and anyway I much prefer using ``tabularx`` if given a choice. Moreover, even for drafts, I like to have my tables looking decently, but I definitely do not want to spend time on them every time I change my specifications a tiny bit, or when I want to add an outcome variable. I want stata to spit out files that latex can read without any manual tinkering.
    * Bonus: Having a structured workflow makes it way easier to go back to the code of a paper after months of waiting for referee reports...

This type of workflow consists of essentially three **separate** steps.
1. Run regressions and save them
2. Turn regressions into *matrixes* and feed these matrixes to write_mats.ado
3. Prepare the skeleton of tables in latex, and point the file to the location where you are saving the final tables

In this repository I uploaded a few files and examples you might find useful if you want to replicate (part of) this workflow. Specifically:

**run_regressions.do:** This file simulates a very simple dataset, runs some OLS and IV regressions on it, and saves the regression results into the estimates/sim folder

**write_tables.do:** This file loads and compiles the regression results into matrixed, calls ``write_mats`` and exports the tables in ``.tex`` format. In the repo you can also find some estimates that [Jeppe Druedahl](http://web.econ.ku.dk/druedahl/) and I use in our joint paper, [Long-Run Saving Dynamics: Evidence from Unexpected Inheritances](https://swopec.hhs.se/lunewp/abs/lunewp2016_007.htm) (a cool paper, check it out!). Note that
