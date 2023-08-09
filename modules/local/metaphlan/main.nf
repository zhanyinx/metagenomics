process metaphlan {
    container "docker://biobakery/metaphlan:4.0.2"

    cpus 15
    memory '20G'
    
    input:
    tuple val(patient), path(sample_path), val(population)


    output:
    tuple val(patient), path("*profiled_metagenome.txt")    , emit: profile
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    for file in `ls ${sample_path}/*.fastq.gz | grep -v _I`; do
        zcat \$file >> ${patient}.fastq
    done

    metaphlan ${patient}.fastq --bowtie2out ${patient}.fastq.bowtie2.bz2 \
            --nproc ${task.cpus} \
            --input_type fastq \
            -o ${patient}.profiled_metagenome.txt \
            --bowtie2db ${params.bowtie2db}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(echo \$(metaphlan 2>&1) | head -n 1 | grep -o "metaphlan Version [0-9.]*" | sed 's/metaphlan Version //' )
    END_VERSIONS

    """
}