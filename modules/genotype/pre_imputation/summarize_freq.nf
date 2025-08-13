/*
Step 1
Calculate allele frequencies for the variants in the .bgen files using PLINK2.
The outputs are .afrq files for each chromosome with variant frequencies.
*/
process SUMMARIZE_FREQ {
    tag "chr${chr}"
    //publishDir "${data_path_prefix}/freq", mode: 'copy'
    
    input:
        val chr
        val dataset_name        // Name of the dataset, e.g., "exampleDataset"
        path data_path_prefix   // Path to exampleDataset.bed/.bim/.fam files
    
    output:
        path("${data_path_prefix}/freq/${dataset_name}_chr${chr}.afreq"), emit: freq_file
    
    script:
        """
        mkdir -p "${data_path_prefix}/freq/"

        plink2 \\
            --bfile "${data_path_prefix}/${dataset_name}" \\
            --chr ${chr} \\
            --freq cols=+pos \\
            --out "${data_path_prefix}/freq/${dataset_name}_chr${chr}"
        """
}
