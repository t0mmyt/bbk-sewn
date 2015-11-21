#!/usr/bin/env python
from links import Parser, Compute
import json
import time


class Timer:
    """
    Class to time an event
    """
    def __init__(self):
        pass

    def __enter__(self):
        self.start = time.clock()
        return self

    def __exit__(self, *args):
        self.end = time.clock()
        self.interval = self.end - self.start

# File to read links from
infile = '../../sewn-crawl-2015.txt'
# infile = '../../mini.txt'

# This is the max delta (when all changes are smaller than this PR calculations
# are considered converged
max_delta = 1e-6

# Go!
# Parse input file into an adjecency matrix
with Timer() as t1:
    my_links = Parser(infile)
print "Create adj matrix: %0.6f seconds" % t1.interval

# Get the matrix from the parser
adj_matrix = my_links.adjecency_local

# Prepare PR object
pr_comp = Compute(adj_matrix, my_links.urls_local)

# Write stats from the PR object for in and outlinks
with open('stats.txt', 'w') as f:
    f.write("Outlinks:\n")
    f.write(json.dumps(pr_comp.stats_outlinks, indent=2))

    f.write("\nInlinks:\n")
    f.write(json.dumps(pr_comp.stats_inlinks, indent=2))

# Write the degree distribution tables
with open('degree_dist_outlinks.txt', 'w') as f:
    f.write(json.dumps(pr_comp.degree_dist_out, indent=2))
with open('degree_dist_inlinks.txt', 'w') as f:
    f.write(json.dumps(pr_comp.degree_dist_in, indent=2))

# Make CPU fan spin (do pagerank converging to max_delta)
for t in (0, .15, .25, .5, .75, 1):
    # Re-initialise PR for each t
    pr_comp = Compute(adj_matrix, my_links.urls_local)
    # Work out filename for output
    t_string = "%.2f" % t
    print "t = %s" % t_string
    outfile = "pagerank%s.txt" % t_string.replace('.','')

    # Iterate PR till convergence
    with Timer() as t2:
        delta = 1
        while delta > max_delta:
            delta = pr_comp.pagerank_iter(t=t)
    print "    %d iterations till max_delta < %f" % (pr_comp.iters, float(max_delta))
    print "    Pagerank in %0.6f seconds" % t2.interval

    # Write PR output
    with open(outfile, 'w') as f:
        f.write("# iterations: %d (%f seconds)\n" % (pr_comp.iters, t2.interval))
        f.writelines(["    %70s  %f\n" % (pr_comp.url_list[i], pr_comp.pr[i])
                      for i in range(len(pr_comp.url_list))])
