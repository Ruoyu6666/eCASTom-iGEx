#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
/*
// Pipeline parameters
params.input_gen = null
params.output_dir = "results"
params.min_maf = 0.01 // Minimum Minor Allele Frequency for QC
params.reference_panel = "path/to/reference_panel.vcf.gz" // Path to reference panel
parameters.imputation_type = "genotype"
params.imputation_method = "priler"
#! params.preprocessing_config = "config/preprocessing.json"
#! params.chunk_size = 10000
#! params.help = false
*/


workflow {

    // Step 0: Convert .gen to .bed/.bim/.fam
    gen_to_bed = Channel
        .from(1..22)
        .map { chr ->
            tuple(chr,
                  file("${params.gen_dir}/exampleDataset_chr${chr}.gen"),
                  file("${params.sample_file}")
            )
        }
        | GEN_TO_BED

    // Step 1: Frequency calculation
    freq_channel = gen_to_bed
        .map { chr, bed, bim, fam ->
            tuple(chr, path("exampleDataset_chr${chr}"))
        }
        | SUMMARIZE_FREQ

    // Step 2: Match variants with reference model
    matched_channel = freq_channel
        .map { chr, _ ->
            tuple(
                chr,
                file("${params.data}/exampleDataset_chr${chr}.frq"),
                file("${params.ref_info}"),
                "example",
                "EXP_FREQ_A1_GTEx",
                "0.15",
                file(params.data),
                file("${params.script}/matchGenotypeModel.R")
            )
        }
        | MATCH_VARIANTS

    // Step 3: Filter + align alleles using matched info
    matched_channel
        .map { chr, matched_file ->
            tuple(
                chr,
                file("exampleDataset_chr${chr}"), // bfile prefix from GEN_TO_BED
                matched_file,
                file(params.data)
            )
        }
        | FILTER_REF_ALT
    // Step 4: Format dosage files for PRILER
    filter_channel
        .map { chr, traw_file ->
            tuple(
                chr,
                traw_file,
                file("exampleDataset_chr${chr}.fam"),
                file("${params.script_dir}/format_genotype_dosage.R"),
                "0.1",
                file(params.data)
            )
        }
        | FORMAT_DOSAGE

}
