rule unpack:
    input:
        config['data-dir'] + "data.zip"
    output:
        config['genome'],
        expand(config['samples-dir'] + "{sample}_1_{type}.fq", sample=config['samples'], type=config['types']),
        expand(config['samples-dir'] + "{sample}_2_{type}.fq", sample=['paired_long', 'paired_short'], type=config['types']),
    params:
        dir = config['data-dir']
    benchmark: "benchmarks/unpack/inpack.benchmark.txt"
    log: "logs/unpack/unpack_log.txt"
    shell:"""
        unzip {input} -d {params.dir}  2> {log}
    """