# Spearman's correlations between viruses (metagenomics) and bacteria (16S profiling)

## Input files are located in 01_input_files
"./01_input_files/comp_ratonA.tsv"
"./01_input_files/comp_ratonB.tsv"

## Output files are located in 02_compA and 03_comp3. To obtain the plots rerun the following scripts:

### CompA: Viruses vs CompA
```bash
Rscript spearman_correlations.R -i 01_input_files/comp_ratonA.tsv -o 02_compA --pvalue 0.05 --rvalue 0.5
```

### CompA: Viruses vs CompB
```bash
Rscript spearman_correlations.R -i 01_input_files/comp_ratonB.tsv -o 03_compB --pvalue 0.05 --rvalue 0.5
```

To get more information about the program:
`spearman_correlations.R --help`