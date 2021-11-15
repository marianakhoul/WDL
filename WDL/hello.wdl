## Use double '#' for workflow-level comments
## Introductory workflow

# write the WDL version number 'version 1.0' -- 1
# possible to write 'WDL developent' as a version number as well
version 1.0

# create a workflow called 'HelloWorld'

workflow HelloWorld {
    # execute the 'WriteGreeting' task
    call WriteGreeting 
}

# create a task called 'WriteGreeting' 

task WriteGreeting {
    
   # execute a command which runs 'echo "Hello"'
   command {
      echo "Hello"
    }
    
    # set the output as a file named 'output_greeting' to standard out
    output {
      # write output to standard out
      File output_greeting = stdout()
    }
    
    runtime {    
            # Use this container, pull from DockerHub   
            docker: "ubuntu:latest"    
       } 
}
