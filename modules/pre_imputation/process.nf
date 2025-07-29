// Harmonizing variant sets between reference models and new data
//For custom genotype data to work with PriLer reference models, it must be processed accordingly. 

//First, variants must be filtered to leave only SNPs present in the reference model.

//Second, the definition of reference (REF) and alternative (ALT) alleles must be the same as in the reference model. 
//Depending on the initial processing of the data, this might not be the case (e.g. when alleles are major/minor-coded). 

//Finally (recommended), the frequency of the alternative alleles must not deviate strongly from the data used to train the model, as it can negatively affect the performance.

//These steps are achieved using common genetics software as well as two custom scripts provided with CASTom-iGEx in Software/model_prediction/.


process SUMMARIZE_VARIANTS {
    tag "chr${chr}"
    input:
        val chr
        path bfile_prefix  // Prefix path to .bed/.bim/.fam (no file extension)

    output:
        path "exampleDataset_chr${chr}.afreq"

    script:
        """
        plink2 \\
            --bfile ${bfile_prefix} \\
            --chr ${chr} \\
            --freq cols=+pos \\
            --out exampleDataset_chr${chr}
        """
}


process summarize_variants{
    label 'summarize_variants'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.summary.txt"), emit: summary_file

    script:
    """
    This process summarizes the variants in the input .gen format file.
    """
}

process match_reference_variants{
    label 'match_reference_variants'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.matched.vcf"), emit: matched_vcf

    script:
    """
    This process matches the variants in the input VCF file to those in the reference model.
    It takes a sample ID and a VCF file as input, and outputs a VCF file with matched variants.
    """
}


process harmonize_alleles{
    label 'harmonize_alleles'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.harmonized.vcf"), emit: harmonized_vcf

    script:
    """
    This process harmonizes the alleles in the input VCF file to match those in the reference model.
    It takes a sample ID and a VCF file as input, and outputs a VCF file with harmonized alleles.
    """
}

process format_genotype{
    label 'format_genotype'
    tag "$sample_id"

    conda "${moduleDir}/environment.yml"
    container "${moduleDir}/container.img"

    input:
    tuple val(sample_id), path(vcf_file)

    output:
    tuple val(sample_id), path("*.formatted.vcf"), emit: formatted_vcf

    script:
    """
    This process formats the genotype data in the input VCF file.
    It takes a sample ID and a VCF file as input, and outputs a formatted VCF file.
    """
}