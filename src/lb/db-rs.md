# db-rs

*The story of how Lockbook created its own database for speed and productivity.*

As a backend engineer, the architecture I see used most commonly is a loadbalancer distributing requests to several horizontally scaled API servers. Those API servers are generally talking to one or more stores of state. [Lockbook](https://parth.cafe/p/introducing-lockbook) also started this way, we load balanced requests using HAProxy, had a handful of [Rust API nodes](https://parth.cafe/p/why-lockbook-chose-rust), and stored our data in Postgres and S3.

A year into the project, we had developed enough of the product that we understood our needs more clearly, but we were still early enough into our journey where we could make breaking changes and run experiments. I had some reservations about this *default* architecture, and before the team stabilized our API, I wanted to see if we could do better.

My first complaint was about our interactions with SQL. It was annoying to shuffle data back and forth from the fields of our structs into columns of our tables. Over time our SQL queries grew more complicated, and it was hard to express and maintain ideas like *a user's file tree cannot have cycles* or *a file cannot have the same name as a non-deleted sibling*. We were constantly trying to determine whether we should express something in SQL, or read a user's data into our API server, perform and validate the operation in Rust, and then save the new state of their file tree. Concerns around transaction isolation, consistency, and performance were always hard to reason about. We were growing frusterated because we knew how we want this data to be stored and processed and were burning cycles fighting our declarative environment.

My second complaint was about how much infrastructure we had to manage. While on the topic of Postgres itself, running Postgres at a production scale is not trivial. There's a great deal of trivia you have to understand to make Postgres work properly with your API servers and your hardware. First we had to understand what features of Postgres our database libraries supported. In our case, that meant evaluating whether we needed to additionally run PGBouncer, Postgres' connection pooling server, and potentially another piece of infrastructure to manage. Regardless of PGBouncer, configuring Postgres itself requires an understanding of how Postgres interacts with your hardware. From Postgres' [configuration guide](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server):

> PostgreSQL ships with a basic configuration tuned for wide compatibility rather than performance. Odds are good the default parameters are very undersized for your system.... 

That's just Postgres. Similar complexities existed for S3, HAProxy, and the networking and monitoring considerations of all the nodes mentioned thus far. This was quickly becoming overwhelming, and we hadn't broken ground on *user collaboration*, one of our most ambitious features. For a team sufficiently large this may be no big deal. Just hire some ops people to stand up the servers so the software engineers can engineer the software. For our resource-constrained team of 5, this wasn't going to work. Additionally, when we surveyed the useful work our servers were performing, we knew this level of complexity was unnecessary.

For example, when a user signs up for Lockbook or makes an edit to a file, the actual useful work that our server did to record that information should have taken no more than 2ms. But from our load balancer's reporting, those requests were taking 50-200ms. We were using all these heavy-weight tools to be able to field lots of concurrent requests without paying any attention to how long those requests were taking. Would we need all this if the requests were fast?

We ran some experiments with Redis and stored files in EBS instead of S3, and the initial results were promising. We expressed all our logic in Rust and vastly increased the amount of code we were able to share with our clients (core). We dramatically reduced our latency, and our app felt noticeably faster. However, most of that request time was spent waiting for Redis to respond over the network (even if we hosted our application and database on the same server). And we were still spending time ferrying information in and out of Redis. I knew something was interesting to explore here.

So after a week of prototyping, I created [db-rs](https://github.com/parth/db-rs). The idea was to make a stupid-simple database that could be embedded as a Rust library directly into our application. No network hops, no context switches, and huge performance gains. Have it be easy for someone to specify a schema in Rust, and allow them to pick what the performance characteristics of these simple key-value style tables would be. This is Core's schema, for instance:

```rust
#[derive(Schema, Debug)]
pub struct CoreV3 {
    pub account: Single<Account>,
    pub last_synced: Single<i64>,
    pub root: Single<Uuid>,
    pub local_metadata: LookupTable<Uuid, SignedFile>,
    pub base_metadata: LookupTable<Uuid, SignedFile>,
    pub pub_key_lookup: LookupTable<Owner, String>,
    pub doc_events: List<DocEvent>,
}
```

The types `Single`, `LookupTable`, and `List` are db-rs table types. They are backed by Rust `Option`, `HashMap`, or `Vec` respectively. They capture changes to their data structures, `Serialize` those changes and append them to the end of a log -- one of the fastest ways to persist an event.

The types `Account`, `SignedFile`, `Uuid`, etc are types Lookbook is using. They all implement the ubiquitous `Serialize` `Deserialize` traits, so we never again need to think about converting between our types and their on-disk format. Internally db-rs uses  [`bincode`](https://tyoverby.com/posts/bincode_release.html) format, an incredibly [performant](https://github.com/djkoloski/rust_serialization_benchmark) and compact representation of your data.

What's cool here is that when you query out of a table, you're handed pointers to *your data*. The database isn't fetching bytes, serializing them, or sending them over the wire for your program to then shuffle into its fields. A read from one of these tables is a direct memory access, and because of Rust's memory guarantees, you can be sure that reference will be valid for the duration of your access to it.

What's exciting from an ergonomics standpoint is that your schema is statically known by your editor. It's not defined and running on a server somewhere else. So if you type `db.` you get a list of your tables. If you select one, then that table-type's contract is shown to you, with *your* keys and values. Additionally for us, now our backend stack doesn't require any container orchestration whatsoever: you just need `cargo` to run our server. This has been massive boon for quickly setting up environments whether locally or in production.

The core ideas of the database are less than 800 lines of code and are fairly easy to reason about. This is a database that's working well for us not because of what it does, but because of all the things it *doesn't do*. And what we've gained from db-rs is a tremendous amount of performance and productivity.

Ultimately this is a different way to think about scaling a backend. When you string together 2-4 pieces of infrastructure over the network, you're incurring a big latency cost, and hopefully what you're gaining as a result is availability. But are you? If you're using something like Postgres, you're also in a situation where your database is your single point of failure. You've just surrounded that database with a lot of ceremonies, and I'm skeptical that the ceremony helps Postgres respond to queries faster or that it helps engineers deliver value more quickly.

db-rs has been running in production for half a year at this point. Most requests are replied to in less than 1 ms. we anticipate that on a modest EC2 node, we should be able to scale to hundreds of thousands of users and field hundreds of requests per second. Should we need to, we can  scale vertically 1-2 orders of magnitude beyond this point. Ultimately our backend plans to follow a scaling strategy similar to email where users have a home server. And our long-term vision is one of a network of decentralized server operators. But that's a dream that's still quite far away.

As a result, what Lockbook ultimately converged on, is probably my new *default* approach for building simple backend systems. If this intrigues you, check out the [source code](https://github.com/parth/db-rs) of db-rs or take it for a [spin](https://crates.io/crates/db-rs).

Currently db-rs exactly models the needs of Lockbook. there are key weaknesses around areas of concurrency and offloading seldom accessed data to disk. Whenever Lockbook or one of db-rs' users needs these things, they'll be added. Feel free to open an issue or pull request!

# db-rs (attempt 2)

When [Lockbook](https://parth.cafe/p/introducing-lockbook) first began, it's architecture was I would consider _the typical backend architecture_. When a client would make a request, it would be load balanced to one of several api servers. The selected api server would communicate either Postgres, and S3 to fulfill that request. As we designed the product we understood our needs better and gradually re-evaluated various components of our architecture. We learned a lot through this process and although our needs are not unique, the architecture we're converging towards is unique in it's simplicity: a single api server, running a single [Rust](https://parth.cafe/p/why-lockbook-chose-rust) program. In part this architecture was enabled by an expressive, lightweight, embedded database I wrote called [db-rs](https://github.com/parth/db-rs). Transitioning to this architecture allowed us to move much more quickly and we expect it to (conservatively) handle hundreds of requests a second made by hundreds of thousands of users all for around $50 / month. Today, for most _typical_ projects, this would be my _default_ approach.

Like most backends, we have users who have accounts, accounts manage our domain specific objects: their File. Both users and files have metadata associated with them, users have billing information, files have names, locations, collaboration information, size, etc. 

We were finding that doing typical things in the context of a _typical_ architecture was slow and annoying. For instance much of this data modeling and access would be done with SQL. Your backend however is certainly not written in SQL, so this requires some level of data conversion for **every** field that your server persists. There's likely to be subtle mismatches around how your langauge handles types (limits, signs, encoding) or even meta ideas around types (nullability). You may try an ORM which has it's own strengths and weaknesses. We also found that modeling certain ideas about files was hard to do at the database level: for instance, two files with the same parent cannot have the same name, unless one of them is deleted. Or even trickier: you cannot have a cycle in your file tree. 

Maybe it's silly to try to do this in SQL, so instead you read all the relevant data into your application and run your validations in your server and only write to the database once you're satisfied with the state of your data. But make you're up-to speed on your [transaction isolation types!](https://www.postgresql.org/docs/current/transaction-iso.html) Oh also make sure no one writes to your database without going through your server first otherwise they may invalidate your assumptions. 

Okay maybe you do want to do this in SQL then, so you write a complicated query in a language with very little support for things like tests or package manager. And hope that you've expressed your query and setup your tables in a manner that performs acceptably. Okay let's say you've crossed all those hurdles, let's setup some environments: you can have your team install postgres directly and field complaints about it being a pretty heavy application or you can containerize it and field complaints about docker instead. In production you have to determine whether you need *pg_bouncer* for connection pooling. Okay what about configuring Postgres itself for production, can I just run Postgres on a Linux instance? Nope ([from postgres.org](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)):

> PostgreSQL ships with a basic configuration tuned for wide compatibility rather than performance. Odds are good the default parameters are very undersized for your system.

Not too bad once you read through, but after some reflection *this* was the sort of thing slowing our team down. We had similar interactions with our load balancer and S3. In the past we've had similar intereactions with tools we've seen our day-jobs use at scale. We were ready to try something new to see if we'd have different outcomes. Our application code itself, while complicated, was a tiny fraction of the total request time. We re-architected to eliminate all network traffic from our server, instead of Postgres initially we used a mutex, a bunch of hash tables, and an append only log. Instead of S3 we saved files locally using EBS. We configured our [warp](https://github.com/seanmonstar/warp) rust server to directly handle tls connections rather than our load balancer. Our latencies across all our endpoints were down to less than 2ms without any attention paid to performance within our application layer. We realized we didn't need concurrency, or horizontal scalability just for it's own sake. We wanted our application to be able to scale to the userbase of our dreams, and bringing the latency of each endpoint down by several orders of magnitude was a far easier way to achieve that goal. 

Inspired by the initial results I sat down to see how much progress I could do on the core idea. `db-rs` is what resulted. In `db-rs` you specify your database schema in Rust:

```rust
#[derive(Schema, Debug)]
pub struct CoreV3 {
    pub account: Single<Account>,
    pub last_synced: Single<i64>,
    pub root: Single<Uuid>,
    pub local_metadata: LookupTable<Uuid, SignedFile>,
    pub base_metadata: LookupTable<Uuid, SignedFile>,
    pub pub_key_lookup: LookupTable<Owner, String>,
    pub doc_events: List<DocEvent>,
}
```

A single source of truth, version controlled alongside all your other application logic. The types you see are _your_ Rust types, as long as your type implements the ubiquitous `Serialize` `Deserialize` traits you won't have to write any conversion code to persist your information. You can select a table type with known and straightforward performance characteristics. Everything within the database is statically known. So all your normal rust-related tooling can easily answer questions like "what tables do I have", how do I append to this table? What key does this query expect? What value will it give me?

Moreover, when you query, you're handed references to data from within the database, resulting in the fastest possible reads. When you write, your data is serialized in the [`bincode`](https://tyoverby.com/posts/bincode_release.html) format, an incredibly [performant](https://github.com/djkoloski/rust_serialization_benchmark) and compact representation of your data, persisted to an append-only-log, one of the fastest ways to persist a piece of information generally.

As a result of this new way of thinking about our backend, we don't have to learn the nitty gritty off:
+ SQL
+ Postgres at scale
+ S3
+ Load balancers

Locally using this database is just a matter of `cargo run`'ing your server, which is a massive boon for iteration speed and project onboarding. People trying to self host lockbook (not a use case fully supported just yet, but a priority for us) are going to have a significantly easier time doing so now.

If you're primarily storing things that could be stored within Postgres, and are writing a Rust application, the productivity and performance gains are likely going to be very similar for you. If you had a reference to all your data and could easily generate a response to a given API request within 1ms you're likely also looking at a throughput of hundreds of requests per second. If you're an experienced Rust developer think about how quickly you could get a twitter clone off the ground.

If this intrigues you, checkout the [source code](https://github.com/parth/db-rs) of db-rs or take it for a [spin](https://crates.io/crates/db-rs). The source code is less than 800 significant lines of code, and currently reflects the exact needs of Lockbook. It's very possible that it falls short for you in some way, for instance currently your entire dataset must fit in memory (like Redis), this is fine for Lockbook for the next year or so, but will one day no longer be okay. If this is a problem for you, feel free to open an issue or pull request!


# Lockbook's architectural history (attempt 1)

Today [Lockbook](https://lockbook.net)'s architecture is relatively simple: we have a [core](TODO) library which is used by all clients to connect to a server. Both `core` and `server` are responsible for managing the metadata associated each file and it's content. Our `server` is a single mid-sized ec2 instance, and makes no network connections for file-related operations. Our `core` library communicates directly with our server. Operations that may be traditionally handled by a reverse proxy (ssl connection negotiation, load balancing, etc) are handled by a single [rust](TODO) binary. Our stack achieves throughput and scale by being minimal and fast: our server responds to all file related requests with sub-millisecond latency.

Our stack wasn't always this lean, when we first [set out](https://parth.cafe/p/introducing-lockbook) our stack looked much more traditional: we used `haproxy` to load balance requests and provide tls between 2 server nodes. Our server stored files in `s3` and metadata in `postgres`. In core we stored our metadata in `sqlite`.  For most teams, out growing a simple tool usually takes the form of adopting a more complicated-full-featured version of that tool. For us, outgrowing a tool often involved taking a step back and creating a simpler version of the tool that fit our needs better.

## File contents

Take `s3` for instance. We found that interacting with s3 was becoming too slow, and a source of, albiet rarely, outages. We saw 3 paths forward:
1. Invest deeper in s3. We could expose our users (encrypted) publicly, and have `core` directly fetch files from `s3` instead of having our server abstract this away.
2. Make our architecture more complicated by caching s3 files somewhere.
3. Have our server manage the files itself, locally.

With `s3` we had a handful of crates that we could choose between. If we managed files ourselves (writing locally to a drive), we'd be programming against a significantly more stable and well understood api: Posix System Calls. We could use [ebs](todo) to make various tradeoffs for performance and cost. We would have a slight increase in code complexity as we'd need to learn how to do atomic writes (write the file somewhere temporarily, and atomically rename it when the write is complete). But we'd have a significant decrease in overall engineering complexity: 

+ no need to learn about s3 specific concepts (access control, presigned urls, etc).
+ no need to simulate s3 in environments where using s3 is infeasible (local development, CI, on-prem deployments). No need to wonder if there's subtle differences between various s3 compliant products.
+ significantly smaller surface area of failure.

## File metadata

Initially file metadata was stored in Postgres, and to better understand why we moved away from Postgres, I should explain what our metadata storage goals are. When a user attempts to modify a file in some way we need to enforce a number of constraints. We need to make sure no one modifies someone else's files, no one updates a deleted file, no one puts a tree in an invalid state (cycles, path conflicts, etc), and so on. Initially we tried to express these operations and constraints in SQL and after a couple rounds of iteration it was clear this wasn't the right approach. Our SQL expressions were complicated, hard to maintain, and the source of many subtle bugs.

So we took a step back and moved significant amounts of our logic into rust. The flow of a request was now, a user is trying to perform operation X, fetch all relevant context from the database, perform the operation, run validations, persist the side-effects. This moved most of the complexity back into rust where we could easily write tests, use 3rd party libraries, and iterate quickly with a compiler.

Even with this refactor, we were still largely unsure about our usage of Postgres. Managing Postgres at scale is non-trivial, the surface area of learning how to configure postgres to keep more data in memory and juggle multiple parallel connections (pg-bouncer) is pretty large. Additionally the local development experience of Postgres was pretty poor, it either involved a deep install on your system, or nescesitated containers. And ultimately there were subtle differences between how it may be configured locally and in production, differences which could meaningfully impact the way queries executed. Finally we were willing to do more up-front thinking about how we would store and access data. We didn't need the flexibility of SQL, and found ourselves facing more problems due to the declarative nature of SQL.

Since most of the complicated parts were in Rust, switching to Redis was a fairly inexpensive engineering lift. It was significantly easier to reason about how Redis would behave in various situations and manage it at scale under load. Redis was dropped in as a replacement to Postgres, and with this replacement we were able to eliminate an organization wide dependency on docker. Another set of associated concepts we'd no longer need to reason about to achieve our goals. Our team experienced a vastly better local development experience from this change. 

It was now time to pay attention to `core`. Core shares similar goals to our server with regards to the operations it's trying to perform, but it is additionally constrained by requiring an embedded database and is sensitive to things like startup time and resource requirements. Core also needs to be easy to build for any arbitary rust target, the ideal database would probably be a pure Rust project. Our journey started with SQLite and was a bumpy one initially for some of our compilation targets. But the journey ended the moment we were no longer interested in expressing complicated operations in SQL. Informed by our server-side experience, we left the problem intentionally unsolved for a while as we invested in other areas of the project. We simply persisted our data in a giant JSON files. As we expected while we were in the early days we experienced issues of data corruption as sometimes our writes would be interrupted or multiple processes sharing a data directory would cause data-race-conditions.

### db-rs

After investing in other areas of our project I had done a lot of thinking around databases, especially around what would be ideal for a project that wanted to express as much in Rust as possible. I wanted a database that was fast by virtue of minimalism. For instance, simply being embedded affords your application a massive amount of throughput. For our project, this also meant that we could just stick our database behind a `Mutex` and significantly reduce the number of problems we're trying to solve at the moment. I wanted a database that was designed with rust users in mind and ultra-low-latency. I also wanted to provide rust users with an ergonomic way for users to express a schema, with rust types (not database specific types) and not have them worry about serialization formats.

We needed a database that was:
+ embedded
+ fast
+ ergonomic
+ durable

So in about a week I created [db-rs](https://github.com/parth/db-rs).

Once `db-rs` existed, with the abstractions present in `core` and `server`, it was easy to drop it in. Once again, this simplification boosted performance massively, simplified our code, and simplified our infrastructure, and reduced the number of foreign concepts that our team needed to understand and fbuild around. 

With the request latency the lowest we'd ever seen it, without any significant effort to optimize our code (just eliminate things we didn't want), we also eliminated `nginx` and just had `warp` perform `tls` handshakes and commit to a single server node for the near future. We estimate this modestly priced ec2 instance ($50 / month) can handle hundreds of requests a second from hundreds of thousands of users. If we need to, we have a healthy amount of vertical scaling headroom. Beyond that, our long term plan involves a scaling strategy similar to what's used by self-hosted email.

Today our only remaining project dependency for most work is just the rust toolchain. Local dev environments spin up instantly without the need for any container or network configuration. Deploying a server means building a binary for linux and executing it. 