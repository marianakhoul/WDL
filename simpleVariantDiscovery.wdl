## Howto run a sample variant discovery minipipeline
##
## Reference: https://sites.google.com/a/broadinstitute.org/legacy-gatk-documentation/tutorials/7334-3-howto-Run-a-sample-variant-discovery-minipipeline?authuser=0
##
## Will cover a few more plumbing methods and expand the workflow to include a few more tasks.
## The first 3 taks will come from the simpleVariantSelection.wdl script and will be unchanged.
## Focusing on the 3 new tasks
## Inputs for the hardFilter* tasks will come from their respective previous tasks.
## combine task will take input from both the hardFilter* tasks to combine the outputs.

# WORKFLOW DEFINITION 

workflow SimpleVariantDiscovery {
    
   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
  
  
  call haplotypeCaller {
    input:
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta
  }
  
  call select as selectSNPs {
    input:
    type="SNP",
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta,
    rawVCF=haplotypecaller.rawVCF
  }
  
  call select as selectIndels {
    input:
    type="INDEL",
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta,
    rawVCF=haplotypecaller.rawVCF
  }
    
    call hardFilterSNP {
        inputs:
        sampleName=name,
        GATK=gatk,
        RefIndex=refIndex,
        RefDict=refDict,
        RefFasta=refFasta,
        rawSNPs=selectSNPs.rawSubset
    }
    
    call hardFilterIndel {
        inputs:
        sampleName=name,
        GATK=gatk,
        RefIndex=refIndex,
        RefDict=refDict,
        RefFasta=refFasta,
        rawIndels=selectIndels.rawSubset
    
    }
    
    call combine {
        inputs:
        sampleName=name,
        GATK=gatk,
        RefIndex=refIndex,
        RefDict=refDict,
        RefFasta=refFasta,
        filteredSNPS=hardFilteredSNPs.filteredSNPs
        filteredIndels=hardFilteredIndex.filteredIndels
    }
}

# TASK DEFINITION

task haplotypeCaller {
   
   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
   
   command {
   java -ja ${GATK} \
   -T HaplotypeCaller \
   -R ${RefFasta} \
   -I ${inputBam} \
   -O ${sampleName}.raw.indels.snps.vcf
   }
   
   outputs{
   File rawVCF = "${sampleName}.raw.indels.snps.vcf" 
   }
}

task select {
  
   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
    
   command {
      java -jar ${GATK} \
      -T SelectVariants \
      -R ${RefFasta} \
      -V ${rawVCF} \
      -selectType ${type} \
      -O ${sampleName}_raw.${type}.vcf
   }
   outputs {
      File rawSubset = "${sampleName}_raw.${type}.vcf" 
  }
}

task hardFilterSNP {
    File RefFasta
    File inputBAM
    File GATK
    String sampleName
    File RefIndex
    File RefDict
    File bamIndex
    File rawSNPs
    
    command {
      java -jar ${GATK} \
      -T VariantFilteration \
      -R ${RefFasta} \
      -V ${rawSNPs} \
      --filterExpression "FS>60.0" \ #Based on the GATK guidelines
      --filterName "snp_filter" \
      -O ${SampleName}.filtered.snps.vcf
    }
    
    outputs{
      File filteredSNPs = "${SampleName}.filtered.snps.vcf"
    }
}

task hardFilterIndel {
    File RefFasta
    File inputBAM
    File GATK
    String sampleName
    File RefIndex
    File RefDict
    File bamIndex
    File rawSNPs
    
    command {
      java -jar ${GATK} \
      -T VariantFilteration \
      -R ${RefFasta} \
      -V ${rawSNPs} \
      --filterExpression "FS>200.0" \ #Based on the GATK guidelines
      --filterName "indel_filter" \
      -O ${SampleName}.filtered.indels.vcf
    }
    
    outputs{
      File filteredIndels = "${SampleName}.filtered.indels.vcf"
    }
}

task combine {

    File RefFasta
    File inputBAM
    File GATK
    String sampleName
    File RefIndex
    File RefDict
    File bamIndex
    File filteredSNPs
    File filteredIndels
    
    command {
        java -jar ${GATK} \
        -T CombineVariants \
        -R ${RefFasta} \
        -V ${filteredSNPs} \
        -V ${filteredIndels} \
        --genotypemergeoption UNSORTED \
        -O ${sampleName}.filtered.snps.indels.vcf
    }
    
    outputs {
        File filteredVCF = "${sampleName}.filtered.snps.indels.vcf"
    }
}
