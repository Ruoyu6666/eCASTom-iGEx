process FORMAT_DOSAGE {
    tag "chr${chr}"

    input:
        val chr
        path data_path_prefix
        val dataset_name
        path traw_file
        path fam_file
        path script_path
        val dosage_thresh
    
    output:
        tuple val(chr), path ("${data_path_prefix}/filtered_dosage/${dataset_name}_filtered_ref_alt_dosage_chr${chr}.txt"), emit: formatted_dosage_file
    
    script:
        """
        mkdir -p "${data_path_prefix}/filtered_dosage"

        Rscript ${script_path} \
            --trawFile ${traw_file.baseName} \
            --sampleFile ${fam_file} \
            --sampleNameColumn 2 \
            --dosageThresh ${dosage_thresh} \
            --outDosageFold  "${data_path_prefix}/filtered_dosage"
        """
}

