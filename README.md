Distributed deterministic dataflow programming (with CRDTs!)
=======================================================

Curious about what we're building?  Try out these posts:

* [Programming Models, Part 1: Try Derflow!](http://christophermeiklejohn.com/derflow/erlang/2014/09/28/try-derflow.html)
* [Programming Models, Part 2: QuickChecking Derflow](http://christophermeiklejohn.com/derflow/erlang/2014/10/01/quickchecking-derflow.html)
* [Programming Models, Part 3: Ad Counter, Part 1](http://christophermeiklejohn.com/derflow/erlang/2014/11/16/ad-counter-derflow.html)

To build:

* `make devrel`: Build six development releases.
* `make stagedevrel`: Build six development releases, symlinked to the same source.

To configure for `riak_test`:

* Build development releases: `make stagedevrel`
* Run the setup utility, once: `riak_test/bin/derflow-setup.sh`
* As you modify your code, run `make && riak_test/bin/derflow-current.sh`; this will rebuild your local source and then configure `riak_test` to use the latest version.

To run the tests:

* `make riak-test` to run all integration and program tests.
* `./rebar skip_deps=true eqc` to run the Erlang QuickCheck tests.
