# SecDev 2020 Muse Tutorial

This repository contains all resources and instructions for the Muse tutorial presented at SecDev 2020.

## Requirements
GitHub Account (sign up at: https://github.com)

MuseDev Account (sign up at: https://console.muse.dev)

Muse GitHub App (install from: https://github.com/apps/muse-dev)

Jupyter

    pip3 install notebook

Install Python GitHub Library, and Git Library

    pip3 install pygithub gitpython

Install Python Pandas and Matplotlib Libraries

    pip3 installl pandas matplotlib

Install Muscle (MUse Command Line Environment)

    pip3 install muscle-musedev

Produce a GitHub Token
 * https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

Produce a Muse Authentication Token
 * Email tommd@muse.dev or DM @MDTom on Twitter

### Optional Requirements

Docker Image:
    docker pull musedev/build-test

`jq` command line utility
 * On Mac
 
    `brew install jq`
     
 * On Linux
 
    `apt-get install jq`

## Tutorial

### Fork And Analyze Sample Repo
Go to:
  https://github.com/muse-dev/secdev20-tutorial
and fork the repository.

Log into the Muse Console
  https://console.muse.dev

Find the forked repository and click `analyze`.  About five minutes later you should see a list of results, including one result returned by FindSecBugs that points out an unsafe use of deserialization.

### Observe Pull Request Operation
Using the GitHub edit UI, navigate to the file at:
  vulnerability-java-samples/src/main/java/io/meterian/samples/jackson/ProductsDatabase.java

Click the pencil icon to edit the file.

Add the lines marked with a plus below (they will go right after line 8). Do not copy the '+' character:
```
   import java.util.concurrent.atomic.AtomicInteger;
  +import net.jcip.annotations.ThreadSafe;
  
  +@ThreadSafe
   public class ProductsDatabase {
```

Click 'save' and select 'Create a new branch for this commit and start a pull request.' (you can accept the default branch name or change it)

Click 'Propose changes'.  On the next page, click 'Create pull request'.
You should now see a message from musedev saying 'Pending — Analyzing. Musebot needs a minute'.

In about five minutes you should see the check complete and comments appear in the pull request to indicating that variables in the class are now inconsistently synchronized.
In particular, the 'add' method on line 33 calls 'products.put' under synchronization,
but 'findById' on line 26 calls 'products.get' without synchronization and so a
multi-threaded client may add a product in one thread and have other threads not be
able to find that product even if they call 'findById' after the add occurred.
These results are provided by [Infer](https://github.com/facebook/infer), one of the
Java static analysis tools included in Muse.

While Infer finds five instances of potential data races, only one result is reported in the pull request.  This is because GitHub only allows comments on lines of code that are close to lines that were changed in the pull request. To see the rest of the errors, click on 'Details' in the Muse status line at the bottom of the pull request.

### Create a Custom Tool
Running Infer and the other tools built into Muse is great, but what if you have your own tool that you want to include?  Muse supports a plugin interface that allows you to add custom tools.  We will demonstrate this by adding support for Go by including StaticCheck as a custom static analysis tool.

The documentation for the Muse plugin API is here:
  https://docs.muse.dev/docs/extending-muse/



### Useful Commands
docker run --rm -it -v (pwd):/code musedev/build-test bash
