#!/usr/bin/env python
from links import Parser, Compute
from pprint import pprint
import json
import time

my_links = Parser('../../sewn-crawl-2015.txt')
# my_links = Parser('../../mini.txt')


adj_matrix = my_links.adjecency_local
#
# print adj_matrix

compute = Compute(adj_matrix, my_links.urls_local)

# print "Outlinks"
# print compute.outlinks
# print json.dumps(compute.stats_outlinks, indent=2)
# print json.dumps(compute.degree_dist_out)

# print "\nInlinks"
# print compute.inlinks
# print json.dumps(compute.stats_inlinks, indent=2)
# print json.dumps(compute.degree_dist_in)

# print compute.adj_list_in
# print compute.adj_list_out

start_time = time.time()
delta = 1
while delta > 1e-1:
    delta = compute.pagerank_iter(t=0.15)
    print "iteration: %d" % compute.iters
    print " maxdelta: %f" % delta
elapsed_time = time.time() - start_time

pprint(compute.pr)
print "%d iterations" % (compute.iters)
print "%f seconds" % (elapsed_time)


