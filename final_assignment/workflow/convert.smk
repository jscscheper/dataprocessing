rule bam_to_fastq:
    input:
        bam = "{}"
    conda: config['workdir'] + "envs/convert.yaml"
    output:
        "data/fq/{sample}_{type}.fq"
    log: "logs/convert/{sample}_{type}.log"
    benchmark: "benchmarks/{sample}_{type}.bam.benchmark.txt"
    message: "Converting {input.bam} to {output}"
    shell: """
        if [ \"$(samtools view -c -f 1 {input.bam})\" ]; then
            bamToFastq -i {input.bam} -fq {output} >> {log}
        else
            bamToFastq -i {input.bam} -fq {output} -fq2 {output} >> {log}
        fi
        """