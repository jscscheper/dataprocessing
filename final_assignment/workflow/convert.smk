rule bam_to_fastq:
    input:
        bam = config['bam-dir'] + "{sample}_{type}.bam"
    conda: config['workdir'] + config['conda-envs'] + "convert.yaml"
    output:
        config['samples-dir'] + "data/samples/{sample}_{type}.fq"
    log: "logs/convert/{sample}_{type}.log"
    benchmark: "benchmarks/{sample}_{type}.bam.benchmark.txt"
    message: "Converting BAM ({input.bam}) to FastQ ({output})..."
    shell: """
        if [ \"$(samtools view -c -f 1 {input.bam})\" ]; then
            bamToFastq -i {input.bam} -fq {output} 2> {log}
        else
            bamToFastq -i {input.bam} -fq {output} -fq2 {output} 2> {log}
        fi
        """