rule snp_calling:
    input:
        bam = config['samtools-dir'] + "{sample}_{type}_sorted.bam"
    output:
        config['snp-dir'] + "{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "snps.yaml"
    benchmark: "benchmarks/{sample}_{type}.snps.snp_calling.benchmark.txt"
    params:
        genome = config['genome']
    log: "logs/snps/{sample}_{type}.snp_calling.txt"
    message: "Calling SNPs on {input.bam} to {output}"
    shell: """(samtools mpileup -Q 30 -C 50 -P Illumina -t DP,DV,INFO/DPR,DP4,SP,DV -Buf {params.genome} {input.bam} | bcftools view -vcg --types snps - > {output}) 2 > {log}"""

rule snp_filter:
    input:
         config['snp-dir'] + "{sample}_{type}.txt"
    output:
         config['snp-dir'] + "filtered_{sample}_{type}.txt"
    conda: config['workdir'] + config['conda-envs'] + "snps.yaml"
    benchmark: "benchmarks/{sample}_{type}.snps.snp_filter.benchmark.txt"
    log: "logs/snps/{sample}_{type}.snp_filter.txt"
    message: "Filtering SNPs on {input} to {output}"
    shell: "node scripts/snpsPicker.js -i {input} -o {output} 2 > {log}"

rule identifying_and_annotating_snps:
    input:
        mutant =  config['snp-dir'] + "filtered_{sample}_mut.txt",
        control = config['snp-dir'] + "filtered_{sample}_wt.txt"
    output:
         config['snp-dir'] + "{sample}_annotated_snps.txt"
    log: "logs/snps/{sample}.identifying_and_annotating_snps.txt"
    message: "Identifying and annotating SNPs on {input} to {output}"
    benchmark: "benchmarks/{sample}_snps.identifying_and_annotating_snps.benchmark.txt"
    conda: config['workdir'] + config['conda-envs'] + "snps.yaml"
    shell:
     """
     (subtractBed -a {input.control} -b {input.mutant} | snpEff Arabidopsis_thaliana -noLog -v - > {output}) 2 > {log}
     """