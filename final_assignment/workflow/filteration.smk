rule trim_galore:
    input:
        lambda wildcards: get_files(wildcards, base_dir='data/fq/')
    output:
        R1 = "data/trimmed/{sample}_1_{type}_val_1.fq",
        R2 = "data/trimmed/{sample}_2_{type}_val_2.fq"
    message: "Trimming on "
    log: "logs/quality_filteration/{sample}_{type}.log"
    benchmark: "benchmarks/{sample}_{type}.trimmed.benchmark.txt"
    params:
        dir = config['trimmed-dir']
    run:
        # Files are named "{sample}_trimmed.fq" when single-read and "{sample}_val_1/2" for paired-end, we can't force
        # trim_galore to change behaviors and to have one simplified format, therefore, we rename the paired-end reads
        # to the same format as for single-end reads

        if len(input) == 1:
        # STILL NEEDS A FIX
            shell("trim_galore -o {params.dir} --no_report_file {input} > {output.R1}")
            shell("touch {output.R2}")
        else:
            shell("trim_galore -o {params.dir} --no_report_file --paired {input}")
        