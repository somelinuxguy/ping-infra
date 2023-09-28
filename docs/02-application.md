# Application

We are using ping-app for this. I've written that, and [you can find it here](https://github.com/somelinuxguy/ping-app)

That app has its own README but I'll extend that a bit for this exercise.

The app is a tiny express app, it serves only two endpoints (or paths or URLs as you like). I've also included a little test written with the mocha/chai stack because it is relatively small and easy to use, but also it feels a lot like shell scripting with Expect and I'm very old so unix tools feel like home to me.

Now that the application exists, our goal is to incorporate it in to our pipeline project in The Right Way(tm).

## Deployment

The app itself here is a bit irrelevant to the overall point of this demo, suffice it say there is an app that runs a web service and returns some strings.

The real fun is in the .github directory. This is where the workflow(s) live. Github is pretty much aware of them when the exist in this magical folder, so be careful what you write here. Our focus is dev, which is our dev branch and also our workflow.

We've writte it to trigger a github workflow named DevBuild every time there is a merge to any branch, except for "main." This way as any code is merged to any branch, we'll see it running in the DEV envronment. Ideally we'd have them split up and scoped by something more fancy than just "dev" but for a demo, let's keep it simple: A merge to the dev branch will deploy to the dev environment. We already built that with our infra repo. Nice!

We have only one job: Build and Push

This checks out code, sets up environment, builds the code (npm install), then runs tests. If they pass then we continue to build a docker image from the Dockerfile in the source repo, and check it in to ECR with the tag "latest".

It is agreed that using "latest" is actually a bad idea, string comparisons of the tag from *this image* versus *that image* might not result in your deployment updating because the string is identical. So use good practices and tag your image with the commit hash and then use that.

For speed here, I'm just going to use "latest" but you should change this when going to do production.