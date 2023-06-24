rule trim_galore:
    input:
        lambda wildcards: get_files(wildcards, base_dir=config['samples-dir'])
    output:
        R1 = config['trimmed-dir'] + "{sample}_1_{type}_val_1.fq",
        R2 = config['trimmed-dir'] + "{sample}_2_{type}_val_2.fq"
    message: "Trimming on {input} to create {output.R1} and {output.R2}"
    log: "logs/quality_filteration/{sample}_{type}.log"
    benchmark: "benchmarks/{sample}_{type}.trimmed.benchmark.txt"
    threads: config['threads']
    params:
        dir = config['trimmed-dir'],
        temp_name = config['trimmed-dir'] + "{sample}_1_{type}_trimmed.fq"
    run:
        if len(input) == 1:
        # STILL NEEDS A FIX
            shell("trim_galore --cores {threads} -o {params.dir} --no_report_file {input} 2 > {log}")
            shell("touch {output.R2}")
            shell("mv {params.temp} {output.R1}")
        else:
            shell("trim_galore --cores {threads} -o {params.dir} --no_report_file --paired {input}" 2 > {log})
        