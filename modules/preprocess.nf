process IMPUTE_GENOTYPES_PriLer{
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
}