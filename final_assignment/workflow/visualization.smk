rule visualize:
    input:
        "data/snp/{sample}_annotated_snps.txt"
    output:
        "results/{sample}.png"
    message: "Constructing a visualization of {input} and storing it at {output}"
    log: "logs/visualization/{sample}.txt"
    benchmark: "benchmarks/{sample}.benchmark.txt"
    conda: config['workdir'] + "envs/visualization.yaml"
    shell: "python scripts/visualize.py -i {input} -o {output}"