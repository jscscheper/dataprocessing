rule bwa_index:
    input:
        config['genome']
    output:
        expand(config['genome'] + ".{extension}", extension=config["extensions"])
    message: "Indexing reference genome ({input})... to {output}"
    shell: "bwa index {input}"

rule bwa_alignment:
    input: 
        lambda wildcards: get_files(wildcards, base_dir='data/trimmed/')
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
        touch "{output}"
    else
        if [[ $inputfile == *single* ]]; then
            bwa aln {params.genome} {input} > {params.tmp_file}
            bwa samse {params.genome} {params.tmp_file} {input} > {output}
        else
            bwa aln {params.genome} {input[0]} >> {params.tmp_file}
            bwa aln {params.genome} {input[1]} >> {params.tmp_file2}
            bwa sampe {params.genome} {params.tmp_file} {params.tmp_file2} {input} > {output}
        fi
    fi
    """