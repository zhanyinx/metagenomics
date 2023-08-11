process filtering{
    cpus 1
    memory '1G'
    
    publishDir "${params.outdir}/${params.date}/${patient}", mode: "copy"

    input:
        tuple val(patient), path(metaphlan), val(population) 
    output:
        tuple val(patient), path("*.tsv"), val(population) 
    script:
    """
        awk -F '\\t' 'BEGIN{max="'"${params.ntop}"'"+0.; count=0}{
            if(\$0~/^#/){
                if(\$0~/^#clade_name/){
                    printf "%s\\t%s\\t%s\\t%s\\t%s\\n", "Family","specie","value","mean_control","sd_control"
                }else{
                    print \$0
                }
            }else if((\$0~/t__/)) {
                count++
                split(\$1,array,"|"); 
                for(i=1;i<=length(array);i++) if(array[i] ~ /^f__/ || array[i] ~ /^t__/) printf "%s\\t", array[i] 
                printf "%s\\t%s\\t%s\\n", \$(NF-3), \$(NF-1), \$NF 
                
                if(count>=max){exit}
            }
        }' ${metaphlan} > ${patient}.top${params.ntop}clades.tsv
    """
}