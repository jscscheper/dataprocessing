rule snp_calling:
    input:
        bam = "data/samtools/{sample}_{type}_sorted.bam"
    output:
        "data/snp/{sample}_{type}.txt"
    conda: config['workdir'] + "envs/snps.yaml"
    benchmark: "benchmarks/{sample}_{type}.snps.snp_calling.benchmark.txt"
    params:
        genome = config['genome']
    log: "logs/snps/{sample}_{type}.snp_calling.txt"
    message: "Calling SNPs on {input.bam} to {output}"
    shell: """samtools mpileup -Q 30 -C 50 -P Illumina -t DP,DV,INFO/DPR,DP4,SP,DV -Buf {params.genome} {input.bam} | bcftools view -vcg --types snps> {output}"""

rule snp_filter:
    input:
        "data/snp/{sample}_{type}.txt"
    output:
        "data/snp/filtered_{sample}_{type}.txt"
    conda: config['workdir'] + "envs/snps.yaml"
    benchmark: "benchmarks/{sample}_{type}.snps.snp_filter.benchmark.txt"
    log: "logs/snps/{sample}_{type}.snp_filter.txt"
    message: "Filtering SNPs on {input} to {output}"
    shell: "node scripts/snpsPicker.js -i {input} -o {output}"

rule identifying_and_annotating_snps:
    input:
        mutant = "data/snp/filtered_{sample}_mut.txt",
        control = "data/snp/filtered_{sample}_wt.txt"
    output:
        "data/snp/{sample}_annotated_snps.txt"
    log: "logs/snps/{sample}.identifying_and_annotating_snps.txt"
    message: "Identifying and annotating SNPs on {input} to {output}"
    benchmark: "benchmarks/{sample}_snps.identifying_and_annotating_snps.benchmark.txt"
    conda: config['workdir'] + "envs/snps.yaml"
    shell:
     """
     subtractBed -a {input.control} -b {input.mutant} | snpEff Arabidopsis_thaliana -noLog -v > {output}
     """