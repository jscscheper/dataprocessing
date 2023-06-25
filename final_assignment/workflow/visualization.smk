rule visualize:
    input:
        config['snp-dir'] + "{sample}_annotated_snps.txt"
    output:
        config['result-dir'] + "{sample}.png"
    message: "Constructing a visualization of {input} and storing it at {output}"
    log: "logs/visualization/{sample}.txt"
    benchmark: "benchmarks/{sample}.benchmark.txt"
    shell: "python3 scripts/visualize.py -i {input} -o {output} 2> {log}"