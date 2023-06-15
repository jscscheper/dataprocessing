rule bam_to_fastq:
    input:
        bam = "data/samples/{sample}.bam"
    conda: config['workdir'] + "envs/convert.yaml"
    output:
        fq1 = "data/fq/{sample}.fastq",
        fq2 = optional("data/fq/{sample}_2.fastq")
    log: "logs/convert/{sample}.log"
    benchmark: "benchmarks/{sample}.bam.benchmark.txt"
    message: "Converting {input.bam} to {output}"
    shell: """
        if [ \"$(samtools view -c -f 1 {input.bam})\" ]; then
            bamToFastq -i {input.bam} -fq {output.fq1} >> {log}
        else
            bamToFastq -i {input.bam} -fq {output.fq1} -fq2 {output.fq2} >> {log}
        fi
        """