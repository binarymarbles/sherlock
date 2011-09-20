# Sherlock

[Sherlock](http://www.sherlockapp.org/) is an open source infrastructure
monitoring application.

As of now, its in the super-very-early stages of development, but some
feature highlights will be:

* Server/Agent architecture where agents installed on the servers will push
  metrics to the Sherlock server.
* Gathering of all types of data from agents: process information, load
  information, various data gathered from /proc, network status, contents of
  monitored log files and data gathered by custom plugins.
* Alerting built on user definable criterias against the data provided to
  Sherlock by the agents.
* Indexed and searchable log data from each node.

The Sherlock server itself will be written in
[CoffeeScript](http://jashkenas.github.com/coffee-script/) and will be built
using [Node](http://nodejs.org/).

The system agents have not yet been planned, but they will most likely be
implemented in Ruby or Python.
