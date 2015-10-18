Lasp
=======================================================

[![Build Status](https://travis-ci.org/lasp-lang/lasp.svg?branch=master)](https://travis-ci.org/lasp-lang/lasp)

## Overview

Lasp is a Language for Distributed, Eventually Consistent Computations.

## Information

See all of our papers, examples, and installation guides on the [official Lasp website](https://lasp-lang.org).

## Building

* `rebar3 compile`

## Running

Start 2 nodes:

* `rebar3 shell --sname lasp1 --config config/app1.config`
* `rebar3 shell --sname lasp2 --config config/app2.config`
