##
## My first WDL?CROM workflow
##
## Description:
## This WDL workflow will align paired-end sequences of a sample to
## hg19 build of human genome using bwa mem algorithm, followed by
## sorting and indexing the alignement map using picard
##
## Reference: https://www.rc.virginia.edu/userinfo/howtos/rivanna/wdl-bioinformatics/

############
# Workflow #
############

workflow bwa_mem {
# declare the inputs inside the workflow
  String sample_name
  File r1fastq
  File r2fastq
  File ref_fasta
  File ref_fasta_amb
  File ref_fasta_sa
  File ref_fasta_bwt
  File ref_fasta_ann
  File ref_fasta_pac
  
# decale the calls to the tasks with inputs
  call align {
      input:
        sample_name = sample_name,
        r1fastq = r1fastq,
        r2fastq = r2fastq,
        ref_fasta = ref_fasta,
        ref_fasta_amb = ref_fasta_amb,
        ref_fasta_sa = ref_fasta_sa,
        ref_fasta_bwt = ref_fasta_bwt,
        ref_fasta_ann = ref_fasta_ann,
        ref_fasta_pac = ref_fasta_pac
  }
  
  call sortSam {
      input:
          sample_name=sample_name,
          # output of one file being input of another file pattern call.output
          insam=align.outsam
  }  
}
## tasks outside of the workflow but inside the same WDL script

#########
# Tasks #
#########

## 1. This task will align the reads to the reference using bwa mem

task align {
  String sample_name
  File r1fastq
  File r2fastq
  File ref_fasta
  File ref_fasta_amb
  File ref_fasta_sa
  File ref_fasta_bwt
  File ref_fasta_ann
  File ref_fasta_pac
  Int threads
  
  command {
      bwa mem -M -t ${threads} ${ref_fasta} ${r1fastq} ${r2fastq} > ${sample_name}.hg19-bwamem.sam
  }
  
  runtime {
      cpu: threads
      requested_memory_mb: 16000
  }
  output {
      File outsam = "${sample_name}.hg19-bwamem.sam"
  }
}

## 2. This task will sort sam by coordinate, convert it to BAM, and index the BAM

task sortSam {
    String sample_name
    File insam
    
    command {
        java -jar picard.jar \
            SortSam \
            I= ${insam} \
            O=${sample_name}.hg19-bwamem.sorted.bam \
            SORT_ORDER=coordinate \
            CREATE_INDEX=true     
    }
    output {
        File outbam = "${sample_name}.hg19-bwamem.sorted.bam"
        File outbamidx = "${sample_name}.hg19-bwamem.sorted.bai"
    }
}


## Next steps:
##
## To validate, use wdltool: java -jar $WDLTOOLPATH/wdltool${version}.jar validate bwaAln.wdl
## To specify inputs: java -jar $WDLTOOLPATH/wdltool-${version}.jar inputs bwaAln.wdl > bwaAln.inputs.json
## Add in the inputs to the bwaAln.inputs.json file
## Execute using Cromwell: java -jar $CROMWELLPATH/cromwell-${version}.jar run bwaAln.wdl --inputs bwaAln.inputs.json
##
## Done!











