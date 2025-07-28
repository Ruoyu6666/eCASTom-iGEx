process pre_imputation_qc{
    label 'pre_imputation_qc'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.qc.txt"), emit: qc_file

    script:
    """
    # This process performs quality control on the input VCF file.
    # It takes a sample ID and a VCF file as input, and outputs a QC report.
    """

    when:
    params.imputation_method == "priler"
}