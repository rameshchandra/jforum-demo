jforum-demo
===========

This repository contains scripts to setup a JForum filterer demo. On
Windows, run these scripts in a git bash shell that can clone Nerati
git repositories from github, and also can run maven.

This simple demo is intended to show off our filterer product to the
BOD. It has automated setup steps, and manual steps showcasing the
product. The goal is to show that we can filter out tests that were
not affected by a code change. For this purpose, the demo uses two
test cases and a real JForum commit that affects only one of the
tests. 

The two test cases are (1) creating a new post and (2) quick reply to
a post. The update is r216 in the JForum svn repo. This update only
affects test (1). 

To run, open a git bash shell and:

- mkdir demo
- cd demo
- git clone https://github.com/rameshchandra/jforum-demo.git
- jforum-demo/build\_pkgs.sh
- jforum-demo/copy\_agentjars.sh

You should have already run the first three steps to get access to
this README. 

Then, in one shell run the controller, like so:

- cd demo
- jforum-demo/controller.sh

And in another shell, run Tomcat with JForum, like so:

- cd demo
- jforum-demo/jforum.sh

Now open a browser and browse to http://localhost:8080 and show off the
various controller features:

- Login as admin and show the registered agent injected into JForum
- Login as manager, create a user (Joe), create two tests
  corresponding to the above two tests, and assign tests to the user.
- As manager, create a campaign by uploading
  jforum-demo/jforum-wars/jforum_v1.war
- Login as Joe, and run the tests.

To run the tests, access JForum at http://localhost:8100. For the
first test, click on "new post" and create a test post. For the second
test, choose one of the posts and do a "quick reply".

- Log back in as manager and start another campaign by uploading
  jforum-demo/jforum-wars/jforum_v2.war. This should display the
  impacts, which is the one function that was updated. It should also
  show that only test 1 needs to be rerun.

Currently, this demo is pretty simple. We could easily extend it to
add more tests and larger updates. This may require creating wars of
other JForum svn versions. This is easy and can be done as follows:

- Checkout JForum svn repo using the checkout_jforum.sh script
- Update to the version for which a war is needed:
  - cd jforum2-googlecode; svn update -r<rev> 
- Compile: mvn package -Dmaven.test.skip=true
- The compilation may fail because the pom doesn't specify the Java
  version. Apply the patch jforum-pom.diff to make compilation work:
  - patch -p0 < jforum-pom.diff

TODO
====

- cleanup: split scripts into smaller tasks
- convert this into java
- automate the manual steps so that this can become a test
- add more test cases / changes
