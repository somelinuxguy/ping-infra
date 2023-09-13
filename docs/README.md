# A GitOps Project - The Nitty Gritty Details

Now with 10% less grit, and 20% more nit!

We know from the other file that we need to build an API endpoint (simulated, to keep things easy) and that we need a robust deployment pipeline for it. 

So let's dive right in to *requirements.* Any good project will have walls around it. These might be standards at your company, best practices shared among your team, or even just a few documented "wish list" items in a Jira ticket.

Here are ours:

## Requirements
1. We must use modern best practices (Zero Trust?) for secrets/credentials
1. Infrastructure as Code is an absolute requirement to help us meet automation goals, and also for excellent predictability and repeatability
1. Use GitOps models, such as "a commit is a deploy"
1. Use good repo design, and separation of concern
1. It's not done unless it is tested, and monitored

## The Result
This is what we aim to achieve.

TODO - Let's show a picture here. Everybody likes pictures.

## The Breakdown

Even a seemingly simple project like "Move this code in to production" is actually a series of steps. Like baking a cake, you may see the end result and never see the hundreds of little steps (ingredients, process, safety measures) that create it. It is key to break down your larger problem in to little bits. Bite sized tasks.

You ~~move~~ build a mountain one stone at a time. If you think about [a well formed SDLC](https://aws.amazon.com/what-is/sdlc/) you will probably see this list and think it looks pretty familiar.

### Planning
- [x] Write up READMEs with a reasonable explanation of what we are doing, or will do

### Infrastructure
- [ ] 

### Application

### Deployment

### Monitoring

