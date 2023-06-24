rule bwa_index:
    input:
        config['genome']
    output:
        expand(config['genome'] + ".{extension}", extension=config["extensions"])
    message: "Indexing reference genome {input}..."
    benchmark: "benchmark/genome/genome.txt"
    log: "logs/genome/genome.txt"
    shell: "bwa index {input}"

rule bwa_alignment:
    input: 
        R1 = config['trimmed-dir'] + "{sample}_1_{type}_val_1.fq",
        R2 = config['trimmed-dir'] + "{sample}_2_{type}_val_2.fq"
    output:
        aligned_sam = config['alignment-dir'] + "{sample}_{type}_aln.sam",
        tmp_file =config['alignment-dir'] + temp("{sample}_{type}_1.sai.sa"),
        tmp_file2 = config['alignment-dir'] + temp("{sample}_{type}_2.sai.sa")
    message: "Aligning on {input.R1} and {input.R1} to produce {output.aligned_sam}"
    log: "logs/alignment/{sample}_{type}.txt"
    benchmark: "benchmarks/{sample}_{type}.alignment.benchmark.txt"
    threads: config['threads']
    params:
        genome = config['genome'],
        threshold = config['threshold_reads']
    shell: """
    avglength="$(seqkit fx2tab -nl {input} | awk -F'\\t' '{{sum+=$2}} END {{print sum/NR}}')"
    threshold="{params.threshold}"
    inputfile="{input}"

    if (( $(echo "$avglength > $threshold" | bc -l) )); then
        if [ -s {input.R2} ]; then
            bwa mem -t {threads} {params.genome} {input} - > {output} 2 > {log}
        else
            bwa mem -t {threads} {params.genome} {input.R1} - > {output} 2 > {log}
        fi
    else
        if [[ $inputfile == *single* ]]; then
            bwa aln -t {threads} {params.genome} {input.R1} - > {params.tmp_file} 2 > {log}
            bwa samse {params.genome} {output.tmp_file} {input} - > {output} > 2 {log}
        else
            bwa aln -t {threads} {params.genome} {input.R1} - > {output.tmp_file} 2 > {log}
            bwa aln -t {threads} {params.genome} {input.R2} - > {output.tmp_file2} 2 > {log}
            bwa sampe {params.genome} {output.tmp_file} {output.tmp_file2} {input} - > {output} 2 > {log} 
        fi
    fi
    """