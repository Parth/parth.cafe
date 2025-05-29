+++
title = "Miata Powertrain Trace."
date = 2023-09-23T19:32:33-05:00
draft = true

[taxonomies]
tags = ["wrenching", "miata"]
+++

# Miata Powertrain Trace

If you're a software engineer joining an internet company, a great way to quickly onboard is to follow a "request" through your architecture. "Request" is a vague idea and it's up-to your company to define it, which allows great creative expression in defining what it is the company "does" from an engineering perspective. Tracing this "request" also allows them to give you a tour of all the systems that exist.

Similarly I'd like to follow how "energy" flows through the Miata. I've addressed some of the lower hanging fruit on the Miata and it's time to start considering making more power. Not only now, but what our strategy will be to continuously try to go faster around a track.

At a high level **fuel**, and air are consumed by an **engine**. The engine converts its inputs into a rotational force. This rotational force is gradually transmitted to a **manual transmission** via a clutch. The transmission allows you to step through torque wheelspeed tradeoffs. The transmission uses a drive shaft to transmit the spinning energy to a **differential**. The differential transmits that energy to the rear wheels while still allowing them to spin at different rates.

# Fuel

Energy starts in our fuel tank. Let's talk about fuel choices, it's common to run various grades of octane depending on downstream choices you've made (explored later). For now the stock NA8 Miata requests 11.89 gallons of 87 Octane Gasoline. This amount of fuel weighs 71lbs. As this is a non-trivial amount of weight depending on the type of racings (todo) there may be some strategy involved in how much fuel you carry before you run. However there is a risk in taking too little gas, [in this video](https://youtu.be/PnJQ5hKOi_M?si=3uwn31S0BOTe71le&t=1036) you can see _Gingium_ (one of the few people who have quadrupled the power of the NA6 motor) dropping too low on fuel causes his fuel pump to suck air in a high-g-force-turn. Getting gas in between runs ended up costing him the event, which is particularly dissapointing because he probably would have won otherwise.

![captions](https://lh3.googleusercontent.com/pw/AIL4fc8lGfo1vNwquZoQ7c0YQRyZoaEsRptB8YYhs7qH7d1DLD-L9AgNM3vXMs2i8U1bU4jG_Xyn8K3AUed6RxVY264c2IiQe36RTvL-psmeGDj0DZg7fx44cEjoQSOCMHOveL_MBFO_pWWEizXfkHPMij8LxQ=w822-h528-s-no?authuser=0)

In addition to gasoline, it's common to run [E85](https://en.wikipedia.org/wiki/E85), fuel that's special gas stations stock in addition to gasoline and deisel. You can find an e85 pump [here](https://afdc.energy.gov/fuels/ethanol_locations.html#/find/nearest?fuel=E85), the nearest one to most people reading this blog will be at Newark Airport. E85 is not energy dense, but has combustion properties that allows your ECU (explored later) to switch to a more aggressive tune.

Fuel is _pumped_ from your fuel tank, you may change the fuel pump for e85, or simply to flow more fuel depending on downstream decisions you've made. Fuel is *injected* into the cylinder head for combustion, at which point it's stored energy is converted into a force applied onto the piston head and it's journey being _fuel_ ends.

![](https://lh3.googleusercontent.com/pw/AIL4fc-Ob8l-ZfEbYWNQQLVQlutYYsleWxIBuWLgWicackJ2Y3GAeMQl0WbMuyUNUk-bDXEYeEmGPBDdnEOt6lQHGlloEyb3BKg72xiG5Jo99poqLvkY798-uBQeJZbjwU8VIsWw9w6JsHPZBJWnGw1BQXaq0Q=w878-h480-s-no?authuser=0)
# Engine

The Miata has a world of opportunities open to it for making power, and by understanding all the strategies present to us we can learn a lot about how most cars make power. 

We left off where fuel was being injected into a combustion chamber. Let's talk about all the things that happen in this chamber. A 4 stroke engine performs the following 4 steps perpetually:
1. **Intake**: Brings *the right* mixture of fuel and air into the cylinder via *intake* valves.
2. **Compression**: The piston moves up creating *the right* amount of compression. At a just *the right* time the *ECU* ignites the spark plugs which creates an explosion. 
3. **Power**: The resulting explosion drives the piston down
4. **Exhaust**: *exhaust* valves open allowing gasses to escape the chamber

![](https://upload.wikimedia.org/wikipedia/commons/d/dc/4StrokeEngine_Ortho_3D_Small.gif) 
The pistons drive a crankshaft. Great lengths are gone to keep this process "balanced" as vibrations cause excess strain. The crankshaft ultimately spins a *flywheel* which is interfaces with the *clutch*. The crankshaft is the primary output of the engine.

Let's explore how the right *amount* of things happen at the right *time*. The crankshaft (bottom) is connected via a *timing belt* to 2 *camshafts* (left and right). 

![](https://lh3.googleusercontent.com/pw/AIL4fc8zzNy1sixhqbX2nvDyOnyczFKzif9ixc_mISqga3cYiJ3YdvI_HwKSOP2E0IND39i6eQK_s1QUKCl1wvRMj816kYNa70QdCWhGW7OR37ggSHRAlkc0RhxLTmomqIOgFUD-mxXCdxK_S_3cZh_B-bV6Jw=w400-h384-s-no?authuser=0)
The camshafts look like this. And as they spin the depress valves that open at just the right time relative to the crankshaft. The position of the crankshaft is communicated to the ECU using the *crankshaft position sensor*. The ECU uses this information to control when and how much fuel enters the combustion chamber, and also when the spark plug should fire. 

![](https://lh3.googleusercontent.com/pw/AIL4fc_ZHypQbz1_6GmjpHMzBFyyPz6CG05DJVsc6C5WwTjuMqV_CJThRpoGURVYPMj069dz2RFvUHCC_Y_QnJMP64SZsv-BY9Hth_VTb83ENowXmPd4fnQ-X1YpyrTpi1-k5j8z5nZ2fKeFRs9iHHHP8EIdSQ=w658-h380-s-no?authuser=0)
![](https://lh3.googleusercontent.com/pw/AIL4fc-0Oeq-yVinnu6cCxUGOC5buTeN3IvDB_xDMaKqRpWzC2us31MSiT6j1LiQpyd-s2_ggfh9X3AtAz35hW4cF0-4qoaKRmRYmc7Kj20rp1RFRMsQ_gMrurlN6qlM8ePnXujuLrvyS6D_p55uIYMN9BYi7g=w650-h390-s-no?authuser=0)

![](https://lh3.googleusercontent.com/pw/AIL4fc9fosEtK6EmtYrKqvQs4HKQHiUZFVjMCBnUyUMNorTIbidzUVjJj6HexECbrNX2rYIxfQ0WTA-fSD7x6ZGNAZ1N7wYI-oI8D3g3oTdl534A7sBB7_hUtW7Ld8lrjycGf39VnOIVxPe6E0x0I0nA9uyPYw=w750-h386-s-no?authuser=0)

What drives timing belt is the crankshaft pulley. Similarly there are other accessory systems that are powered via pulley from the crankshaft. These include a water pump that cycles coolant through channels in the engine to keep temperatures down. An oil pump which cycles lubricant through the engine to keep metal-on-metal surfaces lubricated. An alternator which charges the battery. On the Miata power steering, and the AC compressor are also pulley-driven. But on some cars these systems may be powered electronically.

![](https://lh3.googleusercontent.com/pw/AIL4fc-St0lCk8n88JunFnvjaguGqhp2S0F16ROqqouR4hdV_zSXoVFTXx5-PxssKqx_Ql3692c4xaEFzT9VxftdZAgOAWNESQPRhRYqEd2xdGsS2zQOSxHmxVVM9L_iDmIEnHFTQKLrhR_PYQAe1MvRXmjSTg=w680-h426-s-no?authuser=0)

This is the fundementals of an engine, adjusting this process and understanding the various trade-offs involved is how we're going to make more power. So let's explore the various ways the miata community has built more power.

When you look at your tachometer in your car, you're seeing a measure of how often the crankshaft turns (per minute). If the crankshaft is spinning faster, we're doing the full 4 stroke cycle faster, and simply by raising the redline we can make more peak horsepower. *Miata Dad* here explores the physics of [high rpm engine builds](https://youtu.be/6yw_HCvnFu4?si=_FP38AccMHRx4Zvp&t=553). In short there is a non linear relationship between RPM and "stress on your engine". Some engines are designed to be *high-revving*, while some require you to *build-the-engine* (upgrade engine internals). F1 engines, for example rev to 15k RPM, are made of exotic metals. But F1 engines also only are rated for ~1,000 miles of use.

But there are other aspects of an engine you can modify, you can *bore* out the cylinder to increase the amount of air and fuel each stroke is burning. You can see Napp motorsports explore this strategy [here](https://www.youtube.com/playlist?list=PLs9NdPzSO8kuBIWMEjP4o73u48FyxIzVa). Similar to a high rpm build, this requires *building the motor*.

Far more common in the Miata community is forced induction. It's generally easier for us to control liquids than gasses. If we want to get more of a liquid somewhere, we can use bigger pumps and larger lines. But you can't increase fuel without also increasing the amount of air. For every 1 gram of fuel, ideally you would have 14.7 grams of air. Too much air and the air fuel ratio is lean, and too much fuel and your mixture is considered rich. 

In most cars the stock air intake is *restrictive* because it's designed to keep the intake clean in all parts of the world for a wide variety of driving conditions. Induction is also noisy, and making things quiet is not free. The story is similar for most car exhaust systems. Swapping these systems for higher flowing "bolt on systems", and getting a tune is a lot of people's first steps into the world of making their car faster. For the Miata the best case scenario gains are about 10%, *Donut Media* tested this on their *Money Pit Miata*, you can find more info [here](https://www.youtube.com/playlist?list=PLFl907chpCa4WmBZlSv2FfWTiFAwvUeT6). On modern luxury cars intake, exhaust, tune gains can be a significant source of power as you can simply express a different trade-off for fuel efficiency. Personally, I would do these things just for the sounds, they're great. 

![](https://lh3.googleusercontent.com/pw/AIL4fc97Xq4tATbu5dbEeeRuOWCUG0EfNFg9h239JCGIQtN5Qcl_CYgi8udARf3U7GuWjm89YIe_3MptYEbNc5g2bwJRSN4RiHJmS0J8E9kbofaFJoy_O3NuAy1mJF6OJTR7eZ_PrOmnR49IKAGO4Xpns1P3Kg=w1502-h1336-s-no?authuser=0)

But on the Miata, this doesn't get us very far, so if we're going to pump more fuel into the stock cylinder head, we need to turn to some form of *forced induction*. 

The simplest form of forced induction would be to carry a presurized gas and release it into the intake on-demand. This is NoS from the movies. You can see *Miata Dad* explore this [here](https://www.youtube.com/watch?v=ZTS7uYkaVpw). Adding NoS, added a peak of 75HP to the stock NB's ~130HP. This is probably the fastest, most straightforward way to make the Miata faster, but the total gains are limited, getting NoS is annoying and takes up a lot of space in your car. So I won't be researching this any further.

We're already familiar with belt-driven accessories, a *super charger* is simply a belt driven air compressor. As your crankshaft spins faster, the compressor is able to force more air into your intake manifold. In the Miata world there's two common types of superchargers. The [Rotrex](https://trackdogracing.com/Rotrex-18NB.aspx) supercharger and the [MP62](https://www.fastforwardsuperchargers.com/products.html) supercharger.  

![](https://scontent.fewr1-5.fna.fbcdn.net/v/t39.30808-6/211338861_5860006957373692_8070617802517232520_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=49d041&_nc_ohc=mpS96teLdBIAX_uiq0p&_nc_ht=scontent.fewr1-5.fna&oh=00_AfDryAooA8VP5CBnKi_lFmuREnmE6FOtCHBRUWG3VdMTRg&oe=65092B8B)
These superchargers are similar in character, they provide a modest increase in horsepower and torque. The Rotrex is a [centrifugal-type supercharger](https://en.wikipedia.org/wiki/Centrifugal-type_supercharger) which creates most of it's boost in the high rpm range, while the MP62 supercharger is a [roots-type supercharger](https://en.wikipedia.org/wiki/Roots-type_supercharger) providing great low-end torque. Roots-type superchargers have an [intoxicating whine](https://www.youtube.com/watch?v=WxKQZsFglts) as they build boost. Supercharging is one of the two main forms of forced induction, the other is *turbocharging*.

Turbochargers aren't a belt-driven accessory. As exhaust gasses leave the engine, they spin a turbine which pulls air into the engine.

![](https://live.staticflickr.com/7168/6556153357_dcef5891d4_b.jpg)
Turbochargers tend to make more power at the expense of complexity. Boost (intake manifold pressure) is generally in abundance and needs to be regulated via a wastegate. Turbos additionally will require engine oil to be circulated through them. As turbos are harnessing exhaust gasses, engine bay heat starts to become a consideration. Miata superchargers don't have most of these problems and as they make their horsepower without producing too much torque in the low rpms. So if you just want a small bump in power without a significant decrease in reliability supercharging is the way to go. If instead you want a platform which will constantly reach for higher horsepower and torque numbers turbo charging is likely the form of forced induction you want to pursue. 

There is however one other major way to increase your Miata's power output. You can swap in a different motor. Good candidates for motors are generally engines that a car manufacturer built for a wide range of uses. Generally such engines have great power potential and are cheaply available. And in true Miata fashion the aftermarket has rallied around such engines and provided kits that make the swap process as painless as possible. 3 such choices for the Miata are:
+ [Honda's 4 Cylinder K series motors](https://kpower.industries/collections/kmiata-swap-parts/products/ultimate-k24-miata-swap-conversion-package)
+ [Jaguar's 6 Cylinder AJ30 motor](https://www.rocketeercars.com/build-options/self-build) 
+ [Chevy 8 Cylinder LS motor](https://v8roadsters.com/product/lsx/) 
