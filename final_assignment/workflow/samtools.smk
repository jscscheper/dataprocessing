rule view:
    input:
        config['alignment-dir'] + "{sample}_{type}_aln.sam"
    output:
        config['samtools-dir'] + "{sample}_{type}_viewed.bam"
    message: "Indexing on {input} to produce {output}"
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools view -bS -o {output} {input}
    """

rule sort:
    input:
        config['samtools-dir'] + "{sample}_{type}_viewed.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_sorted.bam"
    message: "indexing... "
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools sort -o {output} {input}
    """

rule rmdup:
    input:
        config['samtools-dir'] + "{sample}_{type}_sorted.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_rmdup.bam"
    message: "indexing... "
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools rmdup -s {input} {output}
    """

rule index:
    input:
        config['samtools-dir'] + "{sample}_{type}_rmdup.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_indexed.bam.bai"
    message: "indexing... "
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    log: "logs/samtools/{sample}_{type}.txt"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools index {input} {output}
    """