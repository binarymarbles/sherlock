# Sherlock

Sherlock is an open source infrastructure monitoring application.

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

It will also be using file system based configuration files to set up
everything instead of a database-oriented and UI-administerable configuration
system, to make Sherlock easy to configure and administer using configuration
management tools like [Chef](http://www.opscode.com/). If you have an
infrastructure you care enough about to monitor it, you should care enough to
use Chef or any other similar tools as well. A Chef cookbook will be built for
Sherlock after the initial implementation phase has completed and we have a
working beta release.

The Sherlock server itself is be written in
[Ruby](http://www.ruby-lang.org/en/) utilizing
[EventMachine](http://rubyeventmachine.com/) and
[Sinatra](http://www.sinatrarb.com/).  Metrics are stored in
[MongoDB](http://www.mongodb.org/).

System agents are implemented in Ruby in a [separate
project](http://github.com/tanordheim/watson).
