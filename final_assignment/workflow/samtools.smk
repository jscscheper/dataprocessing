rule view:
    input:
        config['alignment-dir'] + "{sample}_{type}_aln.sam"
    output:
        config['samtools-dir'] + "{sample}_{type}_viewed.bam"
    message: "Indexing on {input} to produce {output}"
    log: "logs/samtools/{sample}_{type}.txt"
    threads: config['threads']
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools view -@ {threads} -bS -o {output} {input} 2 > {log}  
    """

rule sort:
    input:
        config['samtools-dir'] + "{sample}_{type}_viewed.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_sorted.bam"
    message: "Sorting {input} to {output}... "
    log: "logs/samtools/{sample}_{type}.txt"
    threads: config['threads']
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools sort -@ {threads} -o {output} {input} 2 > {log}
    """

rule rmdup:
    input:
        config['samtools-dir'] + "{sample}_{type}_sorted.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_rmdup.bam"
    message: "Removing duplicates from {input}..."
    log: "logs/samtools/{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools rmdup -s {input} {output} 2 > {log}
    """

rule index:
    input:
        config['samtools-dir'] + "{sample}_{type}_rmdup.bam"
    output:
        config['samtools-dir'] + "{sample}_{type}_indexed.bam.bai"
    message: "Indexing {input}..."
    conda: config['workdir'] + config['conda-envs'] + "samtools.yaml"
    log: "logs/samtools/{sample}_{type}.txt"
    benchmark: "benchmarks/{sample}_{type}.index.benchmark.txt"
    shell: """
    samtools index {input} {output} 2 > {log}
    """