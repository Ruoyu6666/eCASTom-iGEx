process impute_genotypes_priler {
    label 'impute_genotypes_priler'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.vcf.gz"), emit: vcf_file

    script:
    """
    priler --input ${vcf_file} --output ${sample_id}.vcf.gz
    """
    when:
    parameters.imputation_type == "genotype" &&
    params.imputation_method == "priler"

    """
    # This process uses the PriLer tool to impute genotypes from VCF files.
    # It takes a sample ID and a VCF file as input, and outputs an imputed VCF file.
    """
}