process IMPUTE_GENOTYPE_PRILER {
    
    tag "impute genotype with PRILER for ${tissue}"
    
    input:
        path data_path_prefix
        val dataset_name
        val tissue
        path model_path_prefix
        val covariates_file
        path script_path

    output:
        path "${data_path_prefix}/results/${tissue}/predictedExpression.txt.gz"
    
    script:
        """
        mkdir -p "${data_path_prefix}/results/${tissue}"

        ::module load palma/2023b GCC/13.2.0 R/4.4.1

        Rscript ${script_path} \\
            --genoDat_file ${data_path_prefix}/filtered_dosage/${dataset_name}_filtered_ref_alt_ \\
            --covDat_file ${data_path_prefix}/${covariates_file} \\
            --outFold ${data_path_prefix}/results/${tissue}/ \\
            --outTrain_fold ${model_path_prefix}/tissues/${tissue}/ \\
            --InfoFold ${model_path_prefix}/tissues/${tissue}/ \\
        """
}