rule bwa_map:
    input:
        "genome.fa",
        config["sample_dir"] + "{sample}.fastq"
    output:
        "mapped_reads/{sample}.bam"
    message: "executing bwa mem on the following {input} to generate the following {output}"
    shell:
        "bwa mem {input} | samtools view -Sb - > {output}"