#!/usr/bin/env python
from links import Parser, Compute

my_links = Parser('../../sewn-crawl-2015.txt')

adj_matrix = my_links.adjecency_local

compute = Compute(adj_matrix, my_links.urls_local)

print compute.outlinks
print compute.inlinks

print compute.stats_inlinks
print compute.stats_outlinks

print compute.degree_dist_in
print compute.degree_dist_out
