# Workflow Description Language (WDL)

WDL allows you to write human readable and writable code for processing workflows.

It has top-level commponents which are _workflow_, _task_ and _call_.
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





