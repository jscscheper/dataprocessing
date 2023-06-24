rule bwa_index:
    input:
        config['genome']
    output:
        expand(config['genome'] + ".{extension}", extension=config["extensions"])
    message: "Indexing reference genome ({input})... to {output}"
    shell: "bwa index {input}"

rule bwa_alignment:
    input: 
        R1 = "data/trimmed/{sample}_1_{type}_val_1.fq",
        R2 = "data/trimmed/{sample}_2_{type}_val_2.fq"
    output:
        aligned_sam = "data/alignment/{sample}_{type}_aln.sam"
    message: "bwa_alignment"
    log: "logs/alignment/{sample}_{type}.txt"
    benchmark: "benchmarks/{sample}_{type}.alignment.benchmark.txt"
    params:
        genome = config['genome'],
        threshold = config['threshold_reads'],
        tmp_file = temp("{sample}_{type}_1.sai.sa"),
        tmp_file2 = temp("{sample}_{type}_2.sai.sa")
    shell: """
    avglength="$(seqkit fx2tab -nl {input} | awk -F'\\t' '{{sum+=$2}} END {{print sum/NR}}')"
    threshold="{params.threshold}"
    inputfile="{input}"

    if (( $(echo "$avglength > $threshold" | bc -l) )); then
        if [ -s {input.R2} ]; then
            bwa mem {params.genome} {input} > {output}
        else
            bwa mem {params.genome} {input.R1} > {output}
        fi
    else
        if [[ $inputfile == *single* ]]; then
            bwa aln {params.genome} {input.R1} > {params.tmp_file}
            bwa samse {params.genome} {params.tmp_file} {input} > {output}
        else
            bwa aln {params.genome} {input.R1} >> {params.tmp_file}
            bwa aln {params.genome} {input.R2} >> {params.tmp_file2}
            bwa sampe {params.genome} {params.tmp_file} {params.tmp_file2} {input} > {output}
        fi
    fi
    """