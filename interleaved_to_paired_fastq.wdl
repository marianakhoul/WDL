## This WDL workflow is used to convert an interleaved fastq file into 2 paired-ended fastq files
##
## Requires 1 interleaved fastq (with extension .fastq)
##
## Outputs: 2 paired-end fastq (one is foward and the other is reverse strands) (with extension .fastq)
## 
## Needs to be 2 fastq files for the FastqToSam GATK tool

version 1.0

# WORKFLOW DEFINITION 

workflow InterleavedToPaired {
  
  File input_file
 
  call InterleavedToPairedFastq{
    input:
      input_fastq=input_file
  }
}

# TASK DEFINITION

task InterleavedToPairedFastq{
  
  input {
    File input_fastq
  }
  
  Int disk_size = ceil(size(input_fastq, "GB") * 2) + 20
  String fastq_file_1 = basename(input_fastq,".fastq") + "_1.fastq"
  String fastq_file_2 = basename(input_fastq,".fastq") + "_2.fastq"
  
  command {
    paste - - - - - - - - < ~{input_fastq} \
    | tee >(cut -f 1-4 | tr "\t" "\n" > ~{fastq_file_1}) \
    | cut -f 5-8 | tr "\t" "\n" > ~{fastq_file_2}
  }
  
  runtime {
    docker: "ubuntu:18.04"
    memory: "8 GB"
    disk: disk_size + " GB"
  }
  
  output {
    File fastq_file_1 = "~{fastq_file_1}"
    File fastq_file_2 = "~{fastq_file_2}"
  }
}
