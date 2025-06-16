# Microservices FAQ

The world is too eager to use microservices. Motivations for splitting a program out into independent servers are on shaky ground. This results in needlessly lower productivity and lower quality software.

## What is a microservice architecture?

An architecture in which several networked small (micro) programs (services) communicate to perform a task. For example, a streaming service may have independent services for `Accounts`, `Recommendations`, `Billing` and `Streaming`. 

## What is a monolith?

A single program which contains all the logic to perform a task. For example, a streaming service may have a monolith with a route for `/accounts`, `/recomendations`, `/billing` and `/streaming`.

## What is strong evidence something should be a microservice?

When the hardware requirements or performance characteristics of your program deviate significantly from your monolith. If your monolith is a traditional, statless, horizontally scalable, REST API and you require the ability to spin up `n` number of stateful game servers for each group of 10 people playing your game, you should probably spin those games up as independent services.

## What is the productivity cost of an unnecessary microservice?

Reasoning about a distributed system is hard. If you needlessly split up your operations into independent services each with their own database you're handicapping your ability to make illegal states unlikely or impossible. 

You're also usually taking calls that would be simple function calls checked by the compiler and turning them into network requests. In the best case this forces you to use tools like grpc, protobuffers. In the worst case this reduces the reliability of your operations. In either case you're going to spend much more time reasoning about how to roll out breaking changes to a distributed system that would otherwise be light refactors.

Infrastructure related productivity abstractions are hard. Your org will likely want a suite of support tools for each service, these can include: monitoring, load-balancing, logging, alerting, etc. You're forcing your company into one of 3 outcomes:

1. hire more operations staff
2. lock yourself into a cloud ecosystem
3. adopt tool(s) like Terraform, Ansible, and other SRE orchestration software.

## Is a monolith harder to scale?

No, you can run `n` replicas of your monolith to achieve the same scale characteristics as your microservices.

## What if I want to _independently_ scale different portions of my app?

You can configure a reverse proxy to only send traffic from a particular route to a particular node, achieving the same flexibility.

## Isn't it about a separation of concern?

You should organize code to separate concerns. Your API framework probably supports the idea of routes, your language probably supports modules, packages or libraries.

## Isn't a microservice architecture more resiliant to failures?

Most architectures have several single points that if failed would result in a total system outage. Generally this is your database. Reasoning about multiple databases is usually not worthwhile and causes more outages than it prevents. More often than not the components of a microservice depend on each other, and there are very few "unimportant" components. In the streaming example, it's very likely that lots of interactions will cause you to engage with the `Account` service to see if a user exists, or the `Billing` service to see if they're allowed to watch something. If there's a significant defect in any major component, it's usually a total outage for most customers.

Microservices don't reduce the need for strong engineering processes that would catch defects (like docs, tests, pr reviews, and other forms of QA).

## Microservices allows team A to work indepenedently of team B

This is usually an organizational problem microservices is hiding.

If team A and team B are working on independent components then each team should be able to make changes to their portion of the monolith and deploy whenever they'd like.

If the two teams are consuming each other's services, then they still need to give the same level of attention to breaking changes. And similar analogues apply whether that interaction is happening over the network or via a function call. 

## Microservices allow my team to deploy more often

The only reason your company shouldn't deploy code that's gone through all the QA processes is if the service is stateful and no level of downtime is permissible due to hard engineering constraints. If you're unable to deploy a stateless rest api without downtime, that should almost certainly become a high engineering priority, and this isn't a good reason to build a microservice in the meantime.

## There are services that are too risky to update

Services that are too risky to update are probably too risky to exist. Microservices here are a bandaid on a problem to which the solution is better engineering processes.

## Microservices allow my company to use different languages

Using different languages has a high cognitive cost, and has some huge missed opportunities for engineering culture.

Different teams have different priorities, the wallet team at a crypto exchange may care about security, while the exchange team may care about performance.

Having these ideas expressed in a single language allows junior engineers to understand contrasting values more clearly. It promotes cross-team collaboration and stewardship rather than silos of ownership. 

Using a single language allows teams to share code, learnings, and expertise across the company. 

There should be incredibly tangible reasons for deviating from an organizations primary language, like the availability of specific tooling that delivers a massive ROI, or the infeasibility of sharing a language across two dramatically different modalities of thinking (frontend / backend and the cost of novel solutions is unacceptable).

More often than not, however multiple languages without strong reasons indicates to me a failure of engineering leadership to define clear values.