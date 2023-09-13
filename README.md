## A GitOps Project

For fun, and to keep my skills up to date, I'm building this. Also because I take a lot from the open source community, I want to give this back to you in the hope that it will help somebody who is having a similar (never the same) problem in search of a solution.

# The problem statement

Let us pretend that a customer needs an API endpoint to return some data. Writing the endpoint is pretty easy, it is just a basic RESTful endpoint that when queried (with a GET) will return something fun and useful.

There are requirements around this though: It has to run "in the cloud" and it has to use modern DevOps practices.

Sounds easy at first, just write a basic app and throw it in the cloud. But it isn't as easy as it seems if you want to make this meet the requirement of Modern DevOps Practices.

# The Battle Plan

To keep the README short, please visit the [docs directory here](https://github.com/somelinuxguy/ping-infra/docs)

# The Result

When all of this is complete our goal is to have a working application that acts as a RESTful API endpoint. Merging code to that application repository will trigger a build process in github actions, and then deployment of the code to an AWS environment. That's the workflow summary.

In order to accomplish this we need to also add a few more tools in to the mix. We will create the AWS environment using Terraform, so that the code has a place to deploy to, and a place to run. The code itself will need some quality control and testing. The docker image we deploy that contains our app will need to be secure.

We will also want to ensure that not just the app is working, we'll also want to make sure that our infrastructure is monitored so we can see healthy and performant (is that a word?) systems. In the case of illness, we should be able to trigger alerts.

See the README in the docs folder for more detailed explanations, steps to accomplish this desired result, and probably more Monty Python jokes.