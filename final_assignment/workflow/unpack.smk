rule unpack:
    input:
        config['data-dir'] + "data.zip"
    output:
        config['genome'],
        expand(config['samples-dir'] + "{sample}_{index}_{type}.fq",
        sample=config['samples'], index=(1, 2), type=config['types'])
    benchmark: "benchmarks/unpack/{input}.benchmark.txt"
    log: "logs/unpack/{input}_log.txt"
    shell:"""
        unzip {input} 2> {log}
    """