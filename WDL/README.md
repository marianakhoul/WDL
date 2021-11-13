# Workflow Description Language (WDL)

WDL allows you to write human readable and writable code for processing workflows.

## Top-level commponents: _workflow_, _task_ and _call_.
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
  input: ref=my_ref,in-task_A.out
  }
}
task task_A{...}
task task_B{...}
```

### call

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

### task

The _task_ component is a top-level component in the WDL script. It contains all the information necessary to "do something" centering around a _command_ accompanied by definitions of input files and parameters, as well as the identification of _output_. Additional components are the _runtime_, _meta_ and _parameter_meta_.

Example:
```
task my_task{
  [input definitions]
  command {...}
  output {...}

}
```

### workflow

The _workflow_ component contains the _call_ statements that invoke the _task_ components.

Example:
```
workflow myWorkflowName{
  call my_task
}
```

## Core task-level components: _command_ and _output_




































