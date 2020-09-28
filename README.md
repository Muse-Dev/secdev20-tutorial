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

Add the lines marked with a plus below (they will go right after line 29). Do not copy the '+' character:
```
  + synchronized
    public Product add(Product newProduct) {
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

Since we are done analyzing the `vulnerability-java-samples` directory, we can remove the Muse config for that sub-project to help future analyses go faster.  Remove the file `vulnerability-java-samples/.muse.toml`.

### Create a Custom Tool

Running Infer and the other tools built into Muse is great, but what if you have your own tool that you want to include?  Muse supports a plugin interface that allows you to add custom tools.  We will demonstrate this by adding support for Go by including StaticCheck as a custom static analysis tool.

The documentation for the Muse plugin API is here:
  https://docs.muse.dev/docs/extending-muse/

A 'hello world' tool is given at the bottom of that page and stored in
the secdev20-tutorial repository as `hello_world_tool.sh`.

Modify `secdev20-tutorial/.muse/config.toml` to say:
    customTools = ["hello_world_tool.sh"]

Go to [console.muse.dev](https://console.muse.dev) and analyze the secdev20-tutorial repo again.  After a few minutes you should see a "Hello World" message among the tool results.

### Try A More Complex Custom Tool

To see a 'Hello World' example with more results, try changing `secdev20-tutorial/.muse/config.toml` to say:
    customTools = ["hello-muse.sh"]

Save and again click the Analyze button on the secdev20-tutorial repo on [console.muse.dev](https://console.muse.dev).  After a few minutes you should see several results that list the files over 1337 lines in the repository with messages stating who checked those files in.

### Add Support For Go's StaticCheck Tool

The file `secdev20-tutorial/staticcheck` contains a 64-bit Linux binary for the Staticcheck tool.

The file `secdev20-tutorial/run_staticcheck.sh` contains a script that downloads this binary as well as its dependencies and runs it
using the Muse Plugin API.

We will use this tool to analyze the "Gen" project.  Go to:

    https://github.com/clipperhouse/gen

Fork the repository.  In your fork of the repo, add a `.muse/` directory containing two files:
 1. `run_staticcheck.sh` (from the `secdev20-tutorial` repo)
 2. `config.toml` (containing the single line `customTools = [".muse/run_staticcheck.sh"]`)

Go to [console.muse.dev)](https://console.muse.dev), find the Gen repo, and click "Analyze".  In a few minutes you should see several results.

### Run Staticcheck using Muscle

First we will set up your Muse API Token.  Assuming a Bash shell, this can be done with the following.

    export MUSEDEV_TOKEN="<token>"

where `<token>` is the string you obtained when you requested a Muse API Token.

To trigger analsis of Gen from the command line, type:

    muscle analyze <gh_username> gen

where `<gh_username>` is your GitHub username.  You should see a job ID printed to the console.
To check status, type:

    muscle status <job_id>

When the job has completed (status is "JobCompletedSuccess"), type:

    muscle results <job_id>
    
to get the results in a JSON format.

### Run Staticcheck at Scale

Load the Jupyter notebook we'll use for our experiments:

    cd notebooks
    jupyter notebook
    
A web browser should open with a list of notebooks.  Open the "Experiments" notebook.
The rest of the tutorial takes place in the "Experiments" notebook and is explained in comments in that notebook.

### Useful Commands

#### Checking Use of the Muse API

You can  use the `check-muse-api.sh` script to check that your custom script conforms to the Muse API. Usage is:

    ./check-muse-api.sh <script_name> <directory>

where `<script_name>` is the name of your custom script and `<directory>` is the directory to run it in (whatever directory contains code for it to analyze).

#### Debugging With Docker 

To debug issues with a custom tool, it can be helpful to run the tool in a docker container that matches Muse's analysis environment.
To do this, type:

    docker run --rm -it -v `pwd`:/code musedev/build-test bash

This will start a docker container that matches Muse's run-time environment and will mount the current directory as `/code` within that container.
You will get a bash terminal and can now try checking out code, running your custom tool, looking at results, and running the `check-muse-api.sh` script.
