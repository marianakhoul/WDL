# Workflow Description Language (WDL)

WDL allows you to write human readable and writable code for processing workflows.
This repository has syntax and explanations of WDL file code snippets and structure. 
It also contains many of the best practice applications required for production pipelines.
A section at the end that focuses mainly on some built in WDL functions used for genomic workflows.

## Breakdown of the README.md file
1. [Base structure of the WDL file](#Base-Structure)
2. [Adding variables into your workflow and tasks](#Add-Variables)
3. [Validating the syntax of your WDL file](#Validate-Syntax)
4. [Generating the input.json file with variables to fill in](#Specify-Inputs)
5. [Run the WDL script using Cromwell execution engine](#Execute)
6. [Basic syntax for building your workflow and tasks](#More-Syntax)
7. []()
8. [References](#References)

## Base Structure

### Top-level commponents: _workflow_, _task_ and _call_.
At the top level, we define a _workflow_ which makes _calls_ to a set of _tasks_.
_Tasks_ are placed outside the _workflow_ while the _call_ statements are placed inside it.

Example:
```
worklow myWorkflowName {
File my_ref
File my_input
String name

call task_A{
  input: ref=my_ref, in=my_input,id=name
  }
  
call task_B{
  input: ref=my_ref,in=task_A.out
  }
}
task task_A{...}
task task_B{...}
```

#### call
The _call_ component is used in the workflow body to specify a particular _task_ to be executed.
In the simplest form, the _call_ only needs a _task_ name. It can also take in input variables for the _task_, and call the _task_ by an alias name. The alias allows the _task_ to be run multiple times with different parameters within the same workflow.

Order of the _call_ statements in the workflow is independent on the order of their execution. It depends on the dependencies between the _tasks_.

Examples:
```
# in the simplest form
call my_task

# with input variables
call my_task {
input: task_var1=workflow_var1, task_var2=workflow_var2,..
}

# with an alias and input variables
call my_task as task_alias{
input: task_var1=workflow_var1, task_var2=workflow_var2,..
}
```

#### task
The _task_ component is a top-level component in the WDL script. It contains all the information necessary to "do something" centering around a _command_ accompanied by definitions of input files and parameters, as well as the identification of _output_. Additional components are the _runtime_, _meta_ and _parameter_meta_.

Example:
```
task my_task{
  [input definitions]
  command {...}
  output {...}

}
```

#### workflow
The _workflow_ component contains the _call_ statements that invoke the _task_ components.

Example:
```
workflow myWorkflowName{
  call my_task
}
```

### Core task-level components: _command_ and _output_
Inside the _task_ definition, we have the _command_, which can be any command line that you can run in a terminal shell, and the _output_ that identifies which part of the _command_ constitutes its output.
_runtime_ allows you to use a docker image to run the task in. Can also specify the CPUs and memory needed.

Example:
```
task task_A{

File ref
File in
String id

  command {
  do_stuff -R ${ref} -I ${in} -O ${id}.ext
  }
  runtime{
  docker:"my_project/do_stuff:1.2.0"
  }
  output{
  File out = "${id}.ext"
  }
}
```

#### command
It is a required component for the _task_. The body of the _command_ block specifies the literal command line to run, with placeholders for the variable parts of the command line that need to be filled. Variable placeholders MUST be defined in the _task_ input definitions.

Example:
```
command {
java -jar myExecutable.jar \ 
  INPUT=${input_file} \
  OUTPUT=${ouput_basename}.txt
}
```

#### output
Also required by the _task_. Used to specify the output(s) of the task _command_ for flow control. Outputs are used to build the workflow graph, include all outputs that are used as inputs to other taks in the workflow. It is okay to not have an _output_ if there is no need for one.

Example:
```
output {
  File out = "${output_basename}.txt"
}
```

## Add Variables
Variables are placeholders that we write into the script instead of the filenames and parameter values. We then specify these parameters at runtime without modifying the script which is convenient. Can hardcode variables that never change from run to run.
If add the variable inside the _task_, specific to this _task_ only. If add the variable at the workflow level, they are available across all tasks.

### Task-level Variables

```
task task_A{

File ref
File in
String id

  command {
  do_stuff -R ${ref} -I ${in} -O ${id}.ext
  }
  runtime{
  docker:"my_project/do_stuff:1.2.0"
  }
  output{
  File out = "${id}.ext"
  }
}
```
R and I are input files while O is the output.
We must first **declare** the variables at the top of the task block example: File ref.
To insert the variable name, R=${ref}.
-O ${id}.ext: the script will concatenate the basename with the .ext extension.
If we want to track outputs of the program, we copy them into the _output_ block and specify the variable type:
output{
  File out = "${id}.ext"
  }
  
### Workflow-level Variables

```
worklow myWorkflowName {
File my_ref
File my_input
String name

call task_A{
  input: ref=my_ref, in=my_input,id=name
  }
  
call task_B{
  input: ref=my_ref,in=task_A.out
  }
}
task task_A{...}
task task_B{...}
```
Declare the variables in the workflow body. To link them to the _tasks_ need to add them in the _call_ using the input: command. If task_B needs task_A output as input, syntax is task_name.output_variable.
Tn the above example, it is task_A.out

## Validate Syntax

WDL comes with a utility toolkit called wdltool that includes syntax validation.
```
$ java -jar wdltool.jar validate myWorkflow.wdl
```
For more information: [https://github.com/broadinstitute/wdltool]

## Specify Inputs
Can generate an input file using wdltools.
```
java -jar wdltool.jar inputs myWorkflow.wdl > myWorkflow_inputs.json
```
  
## Execute
Using cromwell.
```
java -jar cromwell.jar <action> <parameters>
```
Cromwell is an execution engine written in Java and supports running WDL.
Running WDL on Cromwell Locally
```
java -jar Cromwell.jar run myWorkflow.wdl --inputs myWorkflow_inputs.json
```
 
## More Syntax

Primitive data types exist in WDL
+ Boolean
+ Int
+ Float
+ String
+ File
+ Directory

Optional and None
a ? indicates if the value is allowed to be undefined.
Examples:
```
Int certainly_five = 5      # an non-optional declaration
Int? maybe_five_and_is = 5  # a defined optional declaration

# the following are equivalent undefined optional declarations
String? maybe_five_but_is_not
String? maybe_five_but_is_not = None

Boolean test_defined = defined(maybe_five_but_is_not) # Evaluates to false
Boolean test_defined2 = defined(maybe_five_and_is)    # Evaluates to true
Boolean test_is_none = maybe_five_but_is_not == None  # Evaluates to true
Boolean test_not_none = maybe_five_but_is_not != None # Evaluates to false
```

We can also create Arrays. Arrays are ordered lists of elemets of the same type.
```
Array[File] files = ["/path/to/file1", "/path/to/file2"]
File f = files[0]  # evaluates to "/path/to/file1"

Array[Int] empty = []
# this causes an error - trying to access a non-existent array element
Int i = empty[0]
```
When declaring an Array using +, it indicates that the array can not be empty and needs at least 1 element. You can use + and ? together for Arrays.
In the below example, an array of files called fastqs must have at least 1 fastq file.
Depending on the length of the array, we know if it's paired ended or single ended reads for the alignment method. Output is a bam file called output.bam
```
task align {
  input {
    Array[File]+ fastqs
  }
  String sample_type = if length(fastqs) == 1 then "--single-end" else "--paired-end"
  command <<<
  ./align ~{sample_type} ~{sep(" ", fastqs)} > output.bam
  >>>
  output {
    File bam = "output.bam"
  }
}
```

A Pair[X,Y] represents 2 associated values which can be of different types.
```
Pair[Int, Array[String]] data = (5, ["hello", "goodbye"])
Int five = p.left  # evaluates to 5 I think this should be data.left
String hello = data.right[0]  # evaluates to "hello"
```

Map[P,Y] represents a dictionary key-value pair. All keys must be of the same type and all values must be of the same type. Order when elements are added is preserved.
```
Map[Int, Int] int_to_int = {1: 10, 2: 11} # initiate a dictionary called int_to_int with these values
Map[String, Int] string_to_int = { "a": 1, "b": 2 } # initiate a different dictionary where keys are strings
Map[File, Array[Int]] file_to_ints = {
  "/path/to/file1": [0, 1, 2],
  "/path/to/file2": [9, 8, 7]
} # can have values as an array.
Int b = string_to_int["b"]  # evaluates to 2
Int c = string_to_int["c"]  # error - "c" is not a key in the map
```

Can import URL to WDL scripts to use inside your code too
```
import "http://example.com/lib/analysis_tasks" as analysis
import "http://example.com/lib/stdlib.wdl"

workflow wf {
  input {
    File bam_file
  }
  # file_size is from "http://example.com/lib/stdlib"
  call stdlib.file_size {
    input: file=bam_file
  }
  call analysis.my_analysis_task {
    input: size=file_size.bytes, file=bam_file
  }
}
```

~{*expression*} do things to the variables assigned based on the expression
```
Array[File]  a
~{sep=" " a} # sep the elements of array a by space
```

Command section is the only required part of the task. Syntax.
```
# HEREDOC style - this way is preferred
command <<< ... >>> # if adding placeholder value need to use ~{}

# older style - may be preferable in some cases
command { ... } # if adding placeholder value, can use ~{} or ${}

task test {
  input {
    File infile
  }
  command <<<
    cat ~{infile}
  >>>
  ....
}
```

write_array function
```
task write_array {
  input {
    Array[String] str_array
  }
  command <<<
    # the "write_lines" function writes each string in an array
    # as a line in a temporary file, and returns the path to that
    # file, which can then be referenced by other commands such as 
    # the unix "cat" command
    cat ~{write_lines(str_array)}
  >>>
}
```
The runtime section of the task defines a set of key/value pairs that are the minimum requirements needed to run the task. If the engine can't provision the requested resources, the task will fail. 
```
task test {
  input {
    String ubuntu_version
  }

  command <<<
    python script.py
  >>>
  
  runtime {
    container: ubuntu_version
  }
}
```
"The container attribute accepts a URI string that describes a location where the execution engine can attempt to retrieve a container image to execute the task. The format of a container URI string is protocol://location, where protocol is one of the protocols supported by the execution engine. Execution engines must, at a minimum, support the docker:// protocol, and if no protocol is specified, it is assumed to be docker://."[2]
```
task single_image_test {
  #....
  runtime {
    container: "ubuntu:latest"
  }
```
Images defined as ubuntu:laters will reder to a Docker image living on DockerHub.

Scatter-gather is. a common parallelization pattern. Given a collection of inputs (array) the "scatter"step executes the set of operations on each input in parallel. In the "gather" step, the outputs of all the individual "scatter" tasks are collected into the final output.

WDL uses the "scatter-gather" functionality by using a scatter block. 
1. It needs 3 essentials parts. An array to be scattered over.
2. A scatter variable which is an identifier that will hold the input value in each iteration of the scatter. It is always of type Array.
3. A body that contains nested statements.
```
workflow scatter_example {
  input {
    Array[String] name_array = ["Joe", "Bob", "Fred"]
    String salutation = "hello"
  }
  
  # 'name_array' is an identifier expression that evaluates
  #   to an Array of Strings.
  # 'name' is a String declaration that will have a 
  #   different value - one of the elements of name_array - 
  #   during each iteration
  scatter (name in name_array) {
    # these statements are evaluated for each different value
    # of 'name'
    String greeting = "~{salutation} ~{name}"
    call say_hello { input: greeting = greeting }
  }
}
```


## References
1. https://support.terra.bio/hc/en-us/articles/360037117492-Getting-started-with-WDL
2. https://github.com/openwdl/wdl/blob/main/versions/development/SPEC.md#an-example-wdl-workflow



