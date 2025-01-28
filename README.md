# AltECC

This repository includes code to run experiments for alternate ECC objectives, namely Color-Fair ECC and Protected-Color ECC. This code accompanies the paper "Edge-Colored Clustering in Hypergraphs: Beyond Minimizing Unsatisfied Edges".

This repository uses an existing open source repository [ImprovedECC](https://github.com/nveldt/ImprovedECC) for datasets and an implementation of the standard ECC algorithm. After cloning this repository ImprovedECC can be downloaded by running the following.
```
git submodule init
git submodule update
```

In order to run experiments comparing Color-Fair ECC and standard ECC the following command can be run. Output can then be found on standard output and in the table.tex file.
```
julia -- cf_experiments.jl
```

To run experiments comparing Protected-Color ECC standard ECC the following command can be run. Output can then be found in the `out_pc.txt` and `out_ecc.txt` files.
```
julia -- pc_experiments.jl
```
Running the following R script will then generate plots for the Protected-Color ECC expriments.
```
Rscript protected_color_plot.R out_pc.txt out_ecc.txt [out_pdf] legends
```