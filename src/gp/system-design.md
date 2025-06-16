# System Design

When I first started exploring programming I wasn't sure how anything was made. As I learned about the various components of a stack, I started to form a clearer picture of the ways people design systems.

For instance, when I learned about if statements and strings, I understood how people validated forms. And when I learned how to process `stdin` and output to `stdout` I understood how something like `grep` is made. I didn't necessarily understand how to write a regex parser, but I had a good sense of how CLIs come together.

As my understanding matured, I had a sense about why certain designs were successful as well as what we may expect from system design in the future. I'd like to share a snapshot of my current understanding.

When I'm trying to conceptualize the solution to a problem, I start by trying to figure out what shape my work will take. Usually, this is one of the following:

1. Self-standing executable
2. Classic web app
3. Complex web app
4. Novel architecture

# Self Standing executable

A self-standing executable is a piece of software that doesn't have critical external dependencies.

This generally takes the shape of:

+ a static site (like this one)
+ a mobile app
+ a CLI
+ a library
+ a bot
+ some games

These projects are the building blocks of our computing infrastructure. They take a look at a very specific problem and attempt to solve it excellently. There are some unique aspects of such projects:

Software in this category has particularly low maintenance costs. If the solution requires you to maintain a server, it vastly diminishes the long-term survivability of a project. For instance, CLI's (like `grep` or `vim`) or libraries (like `openssl` or TensorFlow) don't require the upkeep of centralized services. While they may evolve and improve, you can probably use a variant from 10 years ago without any issue. And you can probably use that same variant 10 years from now. I would be surprised if the Skype client from 5 years ago worked properly today. It certainly wouldn't work if Skype's servers went offline. On the other hand, how would you go about "killing" `vim`, `openssl`, and similar projects?

Because you don't have to worry about things like maintaining servers, you also don't need to worry about scaling. Static sites are distributed via CDNs, CLIs via package managers, and apps in the App Store. Depending on the idea, you expose yourself to the possibility that your application is virally adopted.

Finally, your ability to prove that your implementation is correct dramatically decreases with the amount of code involved. I'm far more confident in my ability to play audio files locally, than my ability to stream music to my Bluetooth speaker. Consider the difference in the amount of code at play for those examples. Doing things locally, simply, and efficiently reduces the surface area of possible problems.

I think there's a temptation here to monetize this sort of application. This could look something like making people sign up for accounts when that provides no benefit to the experience, or serving them ads. What you sacrifice for doing such things is the possibility for your creation to be widely adopted by all sorts of people across a large period. I doubt `git` would have reached where it is today if you needed to create an account on Linus Torvald's website. Linus Torvalds is living a very comfortable life. I think it's in your best interest to remove as many barriers to mass adoption and create the best product you can. If you do a good job, you'll be okay.

# Classic web app

For a solution to fall into this category it usually necessitates that users create accounts with a centralized service to solve their problem. For instance, social networks, messengers, and banks fundamentally depend on their ability to authenticate users.

These sort of services generally involve:
+ Frontend clients: websites, mobile apps, CLI's
+ API Servers: stateless, horizontally scalable
+ Store of state: some DB which will depend on the type of data and how you access it

There are several technical challenges the come from these additional moving parts. But at this stage, the patterns are still pretty well explored. At some point, your website may become slow because you're getting too much traffic. You'll have to transition from 1 API server to many API servers, you'll likely have to use some sort of a load balancer. It'll be tricky for sure, but lots of people have explored this before you and there shouldn't be too many unknowns after you consume the right resources and ask the right questions.

The most common mistake in this realm is creating un-needed complexity. This could be a premature optimization (involving caches like Redis too early), or could involve splitting their API layer into "microservices". I'll explore this particular mistake in a future post, but the main idea I'd like to stress is: be skeptical of additions to your architecture that stray too far from this model.

# Complex web app

Scaling a classic web app is straightforward because it's known and generally involves adding/upgrading hardware. But sometimes this isn't enough, and your performance needs require you to rethink your architecture. Generally, this happens because the time it takes for various computers to talk to each other introduces too much latency, or because you can't mutate your state (if it's stored in a DB) quickly enough. Generally what you'll end up doing is taking the component that's proving difficult to scale and try to solve the problem with a single computer. Keeping state in RAM instead of on disk, and communicating via function calls rather than network requests.

Let's consider an example: popular games like Dota, Fortnight, Overwatch have to worry about matchmaking, running games, managing item ownership, and processing payments. Everything apart from administering the game logic can likely be engineered as a classic web app. But managing the state of the game (where players are, who did what, who's winning) has tight real-time requirements. By creating a "stateful node" you may be able to meet these real-time requirements, but you have likely created a new set of problems.

Even though you've solved the performance issues that were caused by a database, it's still not clear how you would scale this stateful node to thousands of users. You'll likely need some sort of flexible infrastructure that will let you spin up these game servers on demand.

It's also not obvious how you would achieve high availability. What happens when you want to update your stateful node? In the example of the game, this isn't a significant problem: games are short-lived, new games can start on new versions of the code. However, how do you go about updating the matching engine of an exchange? You can take downtime and lose money, or you invest significant engineering resources to design a matching engine that operates and shares state with multiple nodes and can be upgraded incrementally.

Making this component fault-tolerant can be a non-trivial task as well. In a classic web app, if one node fails you can fall back to the other ones, there was no state in that node, so nothing of importance was lost. However, if your game server experiences a failure, those players likely just disconnected (and are very upset).

This existence of a "stateful node" is just one type of architectural element that turns a "Classic" web app into a "Complex" one. Others can include cron jobs, data pipelines, or specialized hardware. Creating a specialized service that performs well, is highly available and fault-tolerant will likely require a lot of domain-specific knowledge. You won't find a community or textbooks full of answers. You'll likely just have to try several things and learn from experience. Every success, however, becomes a technical edge.

# Novel architecture

Sometimes your problem domain imposes a strong constraint that requires something that hasn't been seen before.

Decentralized projects like Bitcoin, Bittorrent, and Tor are worth studying. All these projects are relatively old, Bitcoin is 10+ years old at the time of writing. The solution that Bitcoin promises: store of value, payment system, created outside the cathedral of big banks and big government had been tried many times before. But due to the way previous attempts were designed, they were shut down. Similarly, early file-sharing apps that were used to pirate music were trivially shut down as well. The problems these tools are trying to solve remained largely unsolved until their decentralized variants emerged.

# Evolution of design

Today's systems look this way because of our prior expectations from our computing infrastructure, as well as the software and hardware limitations of the previous generation of softare.

For instance, it's hard to create a P2P application because of the NAT tables IPv4 necessitates. Addressing devices that don't have fixed IP addresses (all consumer devices) is difficult and requires workarounds like STUN and TURN. New technologies on the horizon as well as an increased appetite for decentralized technologies could lead to a proliferation of P2P applications.

To me, the intersection of our shifting desires (performance, censorship resistance, privacy, etc) and new technologies on the horizon is one of the most exciting areas of our craft and that is why I think these are some of the most valuable problems to work on.