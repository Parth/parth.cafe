# Creating a SICK CLI

At [Lockbook](introducing-lockbook.md) we strongly believe in [dogfooding](https://en.wikipedia.org/wiki/Eating_your_own_dog_food). So we knew alongside a great, native, markdown editing experience we would want a _sick_ CLI. Having a _sick_ CLI creates interesting opportunities for a niche type of user who is familiar with a terminal environment:

* They can use the text editor they're deeply familiar with.
* They can write scripts against their Lockbook.
* They can vastly reduce the surface area of attack.
* Can always maintain remote access to their Lockbook via SSH.

In this post I’m going to tackle 3 topics:

1. What makes a CLI sick?
2. How do you go about realizing some of those “interesting opportunities” using our CLI?
3. What’s next for our CLI?

# What makes a CLI _sick_? 
It’s tab completions. For me, tab completions are what I use to initially explore what a CLI can do. Later, if the CLI is _sick_, I use tab completions to speed up my workflow. I don’t just want to tab complete the structure of the CLI (subcommands and flags). I want to tab complete dynamic values, in Lockbook's case, this means completing file paths and IDs.

![pasted_image_2025-06-16_02-03-26.png](imports/pasted_image_2025-06-16_02-03-26.png)
![pasted_image_2025-06-16_02-03-48.png](imports/pasted_image_2025-06-16_02-03-48.png)
If you're creating a CLI most libraries make you choose between a few bad options:
* Hand-craft completion files for each shell.
* Sacrifice dynamic completions and just settle for automatically generated static completions.

Rust is no exception here, `clap` has some support for static completions, but no way to invoke dynamic completions without writing a completion file for each shell.

And so we set out to solve this problem for the Rust ecosystem, and created `cli-rs`. A parsing library, similar to `clap` but with explicit design priorities around creating a great tab completion experience. As soon as `cli-rs` was stable enough we re-wrote `lockbook`'s CLI using it so we could pass on these gains to our users. 

![pasted_image_2025-06-16_02-04-12.png](imports/pasted_image_2025-06-16_02-04-12.png)
![pasted_image_2025-06-16_02-04-27.png](imports/pasted_image_2025-06-16_02-04-27.png)
Cli-rs is simple, you describe your CLI like this:

```rust
Command::name("lockbook")
    .description("The private, polished note-taking platform.") 
    .version(env!("CARGO_PKG_VERSION"))
    .subcommand(
        Command::name("delete")
            .description("delete a file")
            .input(Flag::bool("force"))
            .input(Arg::<FileInput>::name("target").description("path of id of file to delete")
                        .completor(|prompt| input::file_completor(core, prompt, None)))
            .handler(|force, target| delete(core, force.get(), target.get()))
    )
    .subcommand(
        Command::name("edit")
            .description("edit a document")
            .input(edit::editor_flag())
            .input(Arg::<FileInput>::name("target").description("path or id of file to edit")
                        .completor(|prompt| input::file_completor(core, prompt, None)))
            .handler(|editor, target| edit::edit(core, editor.get(), target.get()))
    )
...
```

This gives the parser all the information it needs to offer the best tab completion behavior. It handles all the static completions internally and then invokes your program when it’s time to dynamically populate a field with your user’s data.

We also invested a ton of effort in the infrastructure that deploys our CLI to our customer's machines so that tab completions would be set up for most people by default.

# Exciting Opportunities for Power Users

## Use your favorite text editor

You can `lockbook edit` any path you have access to and our CLI will invoke `vim`, utilizing any custom `.vimrc` that may exist. You can override the selected editor by setting the `LOCKBOOK_EDITOR` env var or using the `--editor` flag. So far we support `vim`, `nvim`, `subl`, `code`, `emacs` and `nano`.

![pasted_image_2025-06-16_02-05-06.png](imports/pasted_image_2025-06-16_02-05-06.png)

If we don’t support your favorite editor, send us a PR or hop in our [discord](TODO) and tell us.

## Extending Lockbook

We want Lockbook to be maximally extensible, this extensibility will take many forms, one of which is our CLI. Let's explore some of the interesting things you can accomplish with our CLI. 

Let’s say you wanted a snapshot of everything in your second brain decrypted and without any proprietary format for tin-foil-hat backup reasons. You can easily set a `cron` that will simply `lockbook sync` and `lockbook backup` however often you want. `lockbook export` can be used to write any folder or document from Lockbook to your file system, paving the way for automated updates of a blog. Edit a note on your phone, and see the change live on your blog in seconds. `lockbook import` lets you do the opposite. Want to continuously back up a folder from your computer to Lockbook? Setup a `cron` that will simply `Lockbook import` and then `lockbook sync`.

![pasted_image_2025-06-16_02-05-37.png](imports/pasted_image_2025-06-16_02-05-37.png)

## Ultra secure

I like to think about security as the product of a few numbers. So if, for example, you’re product is closed source, one of those numbers in your multiplication chain is a big fat zero. And there’s nothing you can do to pretend it’s secure. Similarly, the age of a product is one of those numbers. Newer is worse, and this is one of Lockbook’s current weaknesses.

But one of Lockbook’s strengths is how much you can reduce the total amount of code it takes to interact with Lockbook. On one end of the spectrum, you have software that **requires** a full browser installation to perform the most basic tasks. Slightly better than that is software that runs natively, and on the other end of the spectrum is software that doesn’t even rely on a UI library. Once we’re mature, if you wanted to run Lockbook on a libre-booted thinkpad running an ultra-minimal operating system, Lockbook wouldn’t require you to add the Google Chrome dependency tree to your setup.

## Remote Lockbook

Sometimes you find yourself employed by a financial institution that heavily restricts what you can do on their machines. Without thinking too much more about your situation you may want to simply add something to your grocery list without pulling out your phone. Unfortunately, IT has locked down your remote Windows 7 installation, and not only can you not install our Windows app (which does not require administrator privileges to install) but you cannot visit GitHub itself!

Maybe in this environment, it’s not worth it to update your grocery list, but you identify with the likes of Ron Swanson, and you will not be defeated by your IT department. How? Because you port forwarded your desktop and memorized a lengthy SSH password. So you ssh in, use your favorite text editor, and you update that grocery list. There’s no stopping you.

# What’s next for our CLI

Our CLI has come a long way, we've experimented with various ways of allowing you to quickly find a note and edit it. In the past we experimented with piping output to programs like `fzf`, we even tried implementing a custom full-screen search. This is the approach that feels the best to us and we think is going to stand the test of time. But work is never done, so here are some of the things we plan to tackle in our CLI:
+ Continue to invest in our release infrastructure to bring our CLI to more package managers. If you'd like to become a maintainer for a particular distro [reach out!](https://discord.gg/lockbook).
+ Support richer parser inputs including variable number of arguments, grouped command line flags, and logical de-duplication of tab completions (this flag or argument is already specified so don't suggest it again).
+ Deeper integrations with shells in `cli-rs`: offer ways to express that this argument is a normal file with completions, or implement mechanisms to re-write the current prompt (`lockbook edit sick<tab>` tab completes: `lockbook edit writing/parth.cafe/creating-a-sick-cli.md` presently tab completion options must begin with the current prompt).
+ A richer showcase of interesting things we can do with our CLI, we plan to set up our blog the way I described above and provide concrete examples of how to do many of the things I outlined. So if you haven't already subscribe to the [Lockbook Blog](https://blog.lockbook.net), and [Lockbook Youtube Channel](https://www.youtube.com/@lockbook_net). 

