process FORMAT_DOSAGE_PRILER {
    tag "chr${chr}"
    input:
        val chr
        path traw_file
        path fam_file
        path script_path
        val dosage_thresh
        path out_dir
    output:
        path "${out_dir}/example_chr${chr}_dosage.txt"
    script:
        """
        Rscript ${script_path} \
            --trawFile ${traw_file.baseName} \
            --sampleFile ${fam_file} \
            --sampleNameColumn 2 \
            --dosageThresh ${dosage_thresh} \
            --outDosageFold ${out_dir}
        """
}