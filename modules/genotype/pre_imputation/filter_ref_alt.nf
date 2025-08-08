/* 
Step 3
Harmonized variant information files are used to filter the genetic data accordingly using PLINK
*/
process FILTER_REF_ALT {
    tag "chr${chr}"

    input:
        val chr
        path data_path_prefix
        val dataset_name      // exampleDataset
        path harmonized_info  // data_path_prefix/matched/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_chr${chr}
    
    output:
        tuple val(chr), path ("${data_path_prefix}/filtered/${dataset_name}_filtered_ref_alt_chr${chr}.traw"), emit: traw_file

    script:
        """
        mkdir -p "${data_path_prefix}/filtered"

        cut -f 3 ${harmonized_info} > snps_chr${chr}.extract

        plink2 \\
            --bfile "${data_path_prefix}/bgen/${dataset_name}" \\
            --chr ${chr} \\
            --extract snps_chr${chr}.extract \\
            --ref-allele force ${harmonized_info} 6 3 \\
            --export A \\
            --out "${data_path_prefix}/filtered/exampleDataset_filtered_ref_alt_chr${chr}"
        """
}