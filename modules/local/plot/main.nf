process barplot{
    cpus 1
    memory '1G'
    
    publishDir "${params.outdir}/${params.date}/${patient}", mode: "copy"

    input:
        tuple val(patient), path(clades) 
    output:
        tuple val(patient), path("*pdf")
    script:
    """
    barplot.py -n ${patient} -i ${clades}
    """
}