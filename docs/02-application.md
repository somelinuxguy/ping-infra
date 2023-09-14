# Application

We are using ping-app for this. I've written that, and [you can find it here](https://github.com/somelinuxguy/ping-app)

That app has its own README but I'll extend that a bit for this exercise.

The app is a tiny express app, it serves only two endpoints (or paths or URLs as you like). I've also included a little test written with the mocha/chai stack because it is relatively small and easy to use, but also it feels a lot like shell scripting with Expect and I'm very old so unix tools feel like home to me.

Now that the application exists, our goat is to incorporate it in to our pipeline project in The Right Way(tm).

## Deployment

We are going to start a whole new document for how we will do the CI/CD for this application. Essentially we'll follow the normal steps of "trigger a workflow" when "something happens in github" and we'll put some walls around that workflow to ensure that bad code is not deployed.

That's where our test suite comes in, as well as an integration with SonarCloud to give us a heads-up when something insecure or stinky gets checked in.

That's about all we need to say about the application here, because the focus of this project is the DevOps stack more than how to design an application.
