[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![Active Development](https://img.shields.io/badge/Maintenance%20Level-Actively%20Developed-brightgreen.svg)](https://gist.github.com/cheerfulstoic/d107229326a01ff0f333a1d3476e068d)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

# Variant annotation and prioritization pipeline

## Contents
- [Contents](#contents)
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Input](#input)
- [Output](#output)

## Overview
Nextflow Implementation for Metagenomics Analysis with MetaPhlAn v4. This workflow executes MetaPhlAn v4 to perform taxonomic profiling and subsequently extracts the most prominent clades. Additionally, it generates clade ranges found in the microbiomes of healthy individuals using the curatedMetagenomicData resource. While currently utilizing raw data generously provided by Paolo Manghi, which is compatible with MetaPhlAn v4, it also offers support for MetaPhlAn v3.

## Installation

Clone the repo

```
git clone git@github.com:zhanyinx/metagenomics.git
```

Download the MetaPhlAn databases from [here](http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/)

The control databases can be downloaded  [missing link]()

## Usage

Update in the configuration file (nextflow.config) by setting the path to the databases:

- bowtie2db: MetaPhlAn databases that can be downloaded from [here](http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/) 

- control_db: control databases that can be downloaded [missing link]()

To run the pipeline

```
nextflow run path_to/main.nf -c yourconfig -profile singularity --input samplesheet.csv --outdir outdir
```

## Input

The nextflow pipeline takes as input a csv samplesheet with 3 columns



__IMPORTANT: HEADER is required__ 

| patient        | sample_path         | population   |
| -------------- | ------------------- | -------------|
| patient1       | path2fastq.gz files | Europe      |
| .....          | .....               | .....        |

sample_path must be provided with full path, __not__ relative path.

Population that the individual belongs to, available options: Europe, Asia, North_America, South_America, Africa, Oceania, all (all population merged).


## Output

Output structure:

```
params.outdir
|-- date
|   `-- patient
|       |-- patient.profiled_metagenome.txt
|       |-- patient.topXX.csv

```

The pipeline outputs for each patient two files

1) patient.profiled_metagenome.txt: the whole MetaPhlAn quantification
2) patient.topXX.csv: the top XX clades with the abundancy found in healthy patients belonging to the same population.
