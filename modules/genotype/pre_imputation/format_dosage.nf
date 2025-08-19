/* 
Step 4
Format dosage files for PRILER using a custom script.
*/
process FORMAT_DOSAGE {
    label 'r_script'
    container 'my_r.sif'
    tag "${dataset_name} format dosage"

    input:
        path data_path_prefix
        val dataset_name
        path fam_file
        path script_path
        val dosage_thresh
        val dummy_trigger // Dummy trigger to ensure the process runs after FILTER_REF_ALT
    
    output:
        path ("${data_path_prefix}/filtered_dosage/${dataset_name}_filtered_ref_alt_chr*"), emit: formatted_dosage_file
    
    script:
        """
        mkdir -p "${data_path_prefix}/filtered_dosage"

        Rscript ${script_path} \\
            --trawFile "${data_path_prefix}/filtered/${dataset_name}_filtered_ref_alt_"\\
            --sampleFile ${fam_file} \\
            --sampleNameColumn 2 \\
            --dosageThresh ${dosage_thresh} \\
            --outDosageFold  "${data_path_prefix}/filtered_dosage/"
        """
}

