# AIActions comment maker

To load the `PharoAIActions` package and use it to create comments for methods, classes, and packages, you need to follow these steps:

### **Load the `PharoAIActions` package using Metacello:**

   Open a Playground in Pharo and execute the following code to load the `PharoAIActions` package:

   ```smalltalk
   Metacello new
       githubUser: 'kasperosterbye' project: 'PharoAIActions' commitish: 'master' path: 'src';
       baseline: 'PharoAIActions';
       load.
   ```
[This is an example of comment generated for the **AIActions** package](AIActionsCommentExample.md)
