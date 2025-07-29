process IMPUTE_GENOTYPE_PRILER {
    tag "${tissue}"
    input:
        val tissue
        path dosage_prefix_dir
        path covariates_file
        path model_dir
        path matched_info_prefix
        path script_path
        path results_dir
    output:
        path "${results_dir}/PriLer_prediction_${tissue}.txt"
    script:
        """
        Rscript ${script_path} \
            --genoDat_file ${dosage_prefix_dir}/exampleDataset_filtered_ref_alt_ \
            --outTrain_fold ${model_dir}/tissues/${tissue}/ \
            --genoInfo_file ${matched_info_prefix}/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_example_ \
            --genoInfo_model_file ${model_dir}/genotype_info/Genotype_VariantsInfo_matched_PGCgwas-CADgwas_ \
            --InfoFold ${model_dir}/tissues/${tissue}/ \
            --covDat_file ${covariates_file} \
            --outFold ${results_dir}/
        """
}