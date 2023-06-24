rule visualize:
    input:
        config['snp-dir'] + "{sample}_annotated_snps.txt"
    output:
        config['results-dir'] + "{sample}.png"
    message: "Constructing a visualization of {input} and storing it at {output}"
    log: "logs/visualization/{sample}.txt"
    benchmark: "benchmarks/{sample}.benchmark.txt"
    conda: config['workdir'] + config['conda-envs'] + "visualization.yaml"
    shell: "python scripts/visualize.py -i {input} -o {output}"