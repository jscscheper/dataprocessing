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
        genome = config['genome'],
        R1 = config['trimmed-dir'] + "{sample}_1_{type}_val_1.fq",
        R2 = config['trimmed-dir'] + "{sample}_2_{type}_val_2.fq"
    output:
        aligned_sam = config['alignment-dir'] + "{sample}_{type}_aln.sam",
        tmp_file = config['alignment-dir'] + temp("{sample}_{type}_1.sai.sa"),
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

    touch {output.tmp_file}
    touch {output.tmp_file2}

    if (( $(echo "$avglength > $threshold" | bc -l) )); then
        if [ -s {input.R2} ]; then
            bwa mem -t {threads} {input.genome} {input} - > {output.aligned_sam}
        else
            bwa mem -t {threads} {input.genome} {input.R1} - > {output.aligned_sam}
        fi
    else
        if [[ $inputfile == *single* ]]; then
            bwa aln -t {threads} {input.genome} {input.R1} - > {output.tmp_file}
            bwa samse {input.genome} {output.tmp_file} {input} - > {output.aligned_sam}
        else
            bwa aln -t {threads} {input.genome} {input.R1} - > {output.tmp_file} 
            bwa aln -t {threads} {input.genome} {input.R2} - > {output.tmp_file2}
            bwa sampe {input.genome} {output.tmp_file} {output.tmp_file2} {input} - > {output.aligned_sam}
        fi
    fi
    """
