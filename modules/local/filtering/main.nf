process filtering{
    cpus 1
    memory '2G'
    
    publishDir "${params.outdir}/${params.date}/${patient}", mode: "copy"

    input:
        tuple val(patient), path(metaphlan), val(population) 
    output:
        tuple val(patient), path("*.csv"), val(population) 
    script:
    """
        grep t__ ${metaphlan} | head -n ${params.ntop} | awk '{print \$1,\$3}' > ${patient}.top${params.ntop}.SGB.txt
        sed -i 's/|/ /g' ${patient}.top${params.ntop}.SGB.txt
        awk '{for(i=0;i<NF;i++) if(\$i ~ /^f__/ || \$i ~ /^t__/) printf "%s ", \$i; print \$NF}' ${patient}.top${params.ntop}.SGB.txt > tmp

        awk '{if(\$0 ~/^#/) print \$0}' ${metaphlan} > ${patient}.top${params.ntop}.csv
        echo "# control database ${params.control_db}/${population}_controls.csv" >> ${patient}.top${params.ntop}.csv
        echo "Family,specie,value,mean_control,sd_control" >> ${patient}.top${params.ntop}.csv

        while read l1 l2 l3; do
                mean=`grep -nr \$l2 ${params.control_db}/${population}_controls.csv | grep \$l2 | awk -F ',' 'BEGIN{n=0; s=0; ss=0}{s+=\$2; n++}END{print s/n; }'`
                sd=`grep -nr \$l2 ${params.control_db}/${population}_controls.csv | grep \$l2 | awk -F ',' 'BEGIN{n=0; s=0; ss=0;m="'"\$mean"'"+0.}{s+=(\$2-m)*(\$2-m); n++}END{print sqrt(s/n); }'`
                echo "\$l1,\$l2,\$l3,\$mean,\$sd" >> ${patient}.top${params.ntop}.csv
        done < tmp
    """
}