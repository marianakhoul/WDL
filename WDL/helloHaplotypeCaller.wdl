## How to write your first WDL script running GATK haploytypecaller
##
##
##
## Reference: https://sites.google.com/a/broadinstitute.org/legacy-gatk-documentation/tutorials/7158-1-howto-Write-your-first-WDL-script-running-GATK-HaplotypeCaller
##
##

# WORKFLOW DEFINITION 

workflow helloHaplotypeCaller {
  call haplotypeCaller{
  }
}


