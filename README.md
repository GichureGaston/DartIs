
# DartIs

DartIs is a Redis-like in-memory key-value store built from scratch using Dart.
It understands the same protocol that Redis uses, so any Redis client can talk to it.

This is a learning project built stage by stage following the CodeCrafters Redis challenge.


## What it does

You can store things by a name, get them back, and make them disappear after a set time.
That is really all a key-value store does. The key is the name, the value is the thing you stored.


## How to run it

Start the server:

    dart run bin/server.dart

In a second terminal, start the interactive client:

    dart run bin/client.dart


## How to use it

Once the client is running, type commands and press enter.

    PING
    SET name Hassan
    GET name
    SET session abc EX 10
    TTL session
    KEYS *
    FLUSHALL

Type HELP to see the full list of commands.
Type EXIT to quit the client.


## How it is built

The project follows clean architecture with two layers that each have one job.

The domain layer is the brain. It knows what a key is, what a value is, and what
operations are allowed. It does not know anything about the network or the screen.

The data layer is the hands. It holds the actual HashMap where keys and values live,
runs timers to expire keys automatically, speaks the RESP protocol over TCP, and
routes incoming commands to the right operation.




## Project structure

    lib/domain       entities, repository interface, use cases
    lib/data         in-memory store, RESP codec, TCP server, command dispatcher
    bin/server.dart  starts the TCP server
    bin/client.dart  interactive command line client


## What is RESP

RESP is the protocol Redis uses to send commands and responses over the network.
Every command is just a list of strings written in a specific format with some
special characters so the server knows where one word ends and the next begins.
The server reads those bytes, figures out what you want, does it, and writes
the answer back in the same format.

## Demo

![description](assets/up.png)



## Built with

    Dart
