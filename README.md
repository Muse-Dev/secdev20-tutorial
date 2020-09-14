# SecDev 2020 Muse Tutorial

This repository contains all resources and instructions for the Muse tutorial presented at SecDev 2020.

## Requirements
Install Muse GitHub App
  https://github.com/marketplace/muse-dev

Install Jupyter
  `pip3 install jupyter`

Install Python GitHub APIs
  `pip3 install github`

Install Muscle (MUse Command Line Environment):
  `pip3 install muscle-muse`

Produce a GitHub Token
https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

Produce a Muse Authentication Token
<Link TBD>

## Tutorial

### Fork And Analyze Sample Repo
Go to:
  https://github.com/muse-dev/secdev20-tutorial
and fork the repository.

Log into Muse Console
https://console.muse.dev

Find the forked repositoory and click analyze.

### Observe Pull Request Operation
Using the GitHub edit UI, navigate to the file at:
  vulnerability-java-samples/src/main/java/io/meterian/samples/jackson/ProductsDatabase.java

Click the pencil icon to edit the file.

Add the lines marked with a plus below (they will go right after line 8). Do not copy the '+' character:
   import java.util.concurrent.atomic.AtomicInteger;
  +import net.jcip.annotations.ThreadSafe;
  
  +@ThreadSafe
   public class ProductsDatabase {

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

### Create a Custom Tool
Running Infer and the other tools built into Muse is great, but what if you have your own tool that you want to include?  Muse supports a plugin interface that allows you to add custom tools.  We will demonstrate this by adding support for Go by including StaticCheck as a custom static analysis tool.

The documentation for the Muse plugin API is here:
  https://docs.muse.dev/docs/extending-muse/


### Useful Commands
docker run --rm -it -v (pwd):/code musedev/build-test bash