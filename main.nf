#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Validate input parameters
WorkflowMain.initialise(workflow, params, log)

// Check input path parameters to see if they exist
def checkPathParamList = [ 
    params.input
    ]

for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.date = new java.util.Date().format('yyMMdd')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { METAGENOMICS } from './workflows/metagenomics'

process help {
    label "help"

    script:
    """
    echo "Usage: nextflow run main.nf -c nextflow.config"
    echo ""
    echo "Perform metagenomics analysis using MetaPhlAn4"
    echo ""
    echo "Options:"
    echo "  --input samplesheet.csv                      CSV file with the following columns:" 
    echo "                                               patient,sample_path,population" 
    echo ""
    """
}

workflow {
   METAGENOMICS()
}