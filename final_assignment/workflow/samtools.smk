rule view:
    input:
        "data/alignment/{sample}_{type}_aln.sam"
    output:
        "data/samtools/{sample}_{type}_viewed.bam"
    message: "indexing... "
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + "envs/samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools view -bS -o {output} {input}
    """

rule sort:
    input:
        "data/samtools/{sample}_{type}_viewed.bam"
    output:
        "data/samtools/{sample}_{type}_sorted.bam"
    message: "indexing... "
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + "envs/samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools sort -o {output} {input}
    """

rule rmdup:
    input:
        "data/samtools/{sample}_{type}_sorted.bam"
    output:
        "data/samtools/{sample}_{type}_rmdup.bam"
    message: "indexing... "
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + "envs/samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools rmdup -s {input} {output}
    """

rule index:
    input:
        "data/samtools/{sample}_{type}_rmdup.bam"
    output:
        "data/samtools/{sample}_{type}_indexed.bam.bai"
    message: "indexing... "
    conda: config['workdir'] + "envs/samtools.yaml"
    log: "logs/samtools/{sample}_{type}.txt"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools index {input} {output}
    """