rule report:
    input:
        "calls/all.vcf"
    output:
        "out.html"
    message: "creating a report with the following {input} to generate the following {output}"
    run:
        from snakemake.utils import report
        with open(input[0]) as f:
            n_calls = sum(1 for line in f if not line.startswith("#"))

        report("""
        An example workflow
        ===================================

        Reads were mapped to the Yeas reference genome 
        and variants were called jointly with
        SAMtools/BCFtools.

        This resulted in {n_calls} variants (see Table T1_).
        """, output[0], metadata="Author: Dennis Scheper", T1=input[0])