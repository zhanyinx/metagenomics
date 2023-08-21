process add_mean_sd_healthy{
    cpus 1
    memory '2G'
    
    publishDir "${params.outdir}/${params.date}/${patient}", mode: "copy"

    input:
        tuple val(patient), path(metaphlan), val(population) 
    output:
        tuple val(patient), path("*.metaphlan.with.ranges.tsv"), val(population) 
    script:
    """
        aenrichment=`grep -nr "t__" ${metaphlan}  | wc -l`
        awk -F '\\t' 'BEGIN{
                print "# control database ${params.control_db}/${population}_controls.csv" > "unchanged"
                print "# alpha enrichment (number of clades): ""'"\$aenrichment"'" > "unchanged"
            }{
                if(\$0~/^#/){
                    if(\$0~/^#clade_name/){
                        printf "%s\\t%s\\t%s\\n", \$0, "mean_healthy", "sd_healthy" > "unchanged"
                    }else{
                        printf "%s\\t%s\\t%s\\n", \$0,"","" > "unchanged"
                    }
                }else if(!(\$0~/t__/)) {
                    printf "%s\\t%s\\t%s\\n", \$0,"","" > "unchanged"
                }else{
                    print \$0 > "replicate.tochange"
                    printf "%s", \$0 > "tochange"
                    split(\$1,array,"|"); 
                    for(i=1;i<=length(array);i++) if(array[i] ~ /^f__/ || array[i] ~ /^t__/) printf "\\t%s", array[i] > "tochange"
                    print "" > "tochange"
                }
            }' ${metaphlan}

        nlines=`wc -l tochange | awk '{print \$1}'`
        for line in `seq 1 \$nlines`; do

            l1=`awk -F '\\t' '{if(NR=="'"\$line"'"+0.) print \$(NF-1)}' tochange`
            l2=`awk -F '\\t' '{if(NR=="'"\$line"'"+0.) print \$(NF)}' tochange`
            fraction_positive=`grep -nr \$l2 ${params.control_db}/${population}_controls.csv | grep \$l2 | awk -F ',' 'BEGIN{n=0; s=0; ss=0}{if(\$2>0) s++; n++}END{print s/n; }'`
            mean=`grep -nr \$l2 ${params.control_db}/${population}_controls.csv | grep \$l2 | awk -F ',' 'BEGIN{n=0; s=0; ss=0}{s+=\$2; n++}END{print s/n; }'`
            sd=`grep -nr \$l2 ${params.control_db}/${population}_controls.csv | grep \$l2 | awk -F ',' 'BEGIN{n=0; s=0; ss=0;m="'"\$mean"'"+0.}{s+=(\$2-m)*(\$2-m); n++}END{print sqrt(s/n); }'`
            awk -F '\\t' '{if(NR=="'"\$line"'"+0.) {
                printf "%s\\t", \$0 >> "unchanged"; 
                printf "%s\\t", "'"\$mean"'" >> "unchanged"; 
                printf "%s\\t", "'"\$sd"'" >> "unchanged"; 
                printf "%s\\n", "'"\${fraction_positive}"'" >> "unchanged"}}' replicate.tochange
        done

        cp unchanged ${patient}.metaphlan.with.ranges.tsv
        
    """
}

