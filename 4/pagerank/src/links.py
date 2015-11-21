from urlparse import urljoin
from collections import OrderedDict
import re
import numpy as np

np.set_printoptions(threshold=np.nan, linewidth=np.nan)


class Parser:
    outbound_full = OrderedDict()
    inbound_full = OrderedDict()
    outbound_local = OrderedDict()
    inbound_local = OrderedDict()
    urls_local = None
    urls_full = None
    is_url = re.compile('^Visited:\s+(.*)$')
    is_link = re.compile('Link:\s+(.*)$')

    def __init__(self, file):
        """
        Read file of links and produce a dict for the unique outbound links per
        page and compute the reverse for inbound links.
        :param file:
        :return: Links object
        """
        # Parse file and record outbound links
        with open(file, 'r') as f:
            line = f.readline().strip()
            while line:
                # Is it a Visited link (url)
                m = self.is_url.match(line)
                if m:
                    url = m.group(1)
                    self.outbound_full[url] = list()

                # Is it a link in a url
                m = self.is_link.match(line)
                if m:
                    # Deal with relative links
                    link = urljoin(url, m.group(1))
                    # We only want unique links
                    if link not in self.outbound_full[url]:
                        self.outbound_full[url].append(link)
                line = f.readline().strip()

        # Find outbound links that do not leave the crawl domain
        for url in self.outbound_full.keys():
            self.outbound_local[url] = list()
            for link in self.outbound_full[url]:
                if link in self.outbound_full.keys():
                    self.outbound_local[url].append(link)

        # Parse outbound links to create reverse map
        for url in self.outbound_full.keys():
            # Do full link list
            for link in self.outbound_full[url]:
                if link not in self.inbound_full.keys():
                    self.inbound_full[link] = list()
                self.inbound_full[link].append(url)
            # Do local link list
            for link in self.outbound_local[url]:
                if link not in self.inbound_local.keys():
                    self.inbound_local[link] = list()
                self.inbound_local[link].append(url)

        self.urls_full = self.outbound_full.keys()
        self.urls_local = self.outbound_local.keys()

    @property
    def adjecency_local(self):
        n = len(self.outbound_local.keys())
        assert n > 0, "Outbound links was empty"
        adj_matrix_local = np.zeros((n, n))
        for url, links in self.outbound_local.iteritems():
            for link in links:
                adj_matrix_local[self.urls_local.index(link), self.urls_local.index(url)] += 1

        return np.matrix(adj_matrix_local)


class Compute:
    matrix = None
    url_list = None
    pr = list()
    iters = 0

    def __init__(self, matrix, url_list):
        """
        Class to compute statistics from a given adjecency matrix
        :param matrix:  numpy.matrix
        :param url_list: list of urls corresponding to adj matrix
        """
        assert isinstance(url_list, list), "url_list was not a list"
        self.matrix = matrix
        self.url_list = url_list
        self.pr = [1] * len(self.url_list)

    def links(self, axis):
        return OrderedDict(zip(
            self.url_list,
            np.array(np.sum(self.matrix, axis=axis, dtype=np.int32).reshape(-1, ))[0].tolist()
        ))

    @property
    def inlinks(self):
        return self.links(axis=1)

    @property
    def outlinks(self):
        return self.links(axis=0)

    @staticmethod
    def stats(links):
        my_stats = OrderedDict()
        my_stats['n'] = len(links)
        my_stats['sum'] = sum(links.values())
        my_stats['mean'] = sum(links.values()) / float(my_stats['n'])
        my_stats['stddev'] = float(np.std(links.values()))
        my_stats['variance'] = float(np.std(links.values()))
        return my_stats

    @property
    def stats_inlinks(self):
        return self.stats(self.inlinks)

    @property
    def stats_outlinks(self):
        return self.stats(self.outlinks)

    @staticmethod
    def degree_dist(links):
        out = OrderedDict()
        for i in sorted(set(links.values())):
            out[i] = links.values().count(i)
        return out

    @property
    def degree_dist_in(self):
        return self.degree_dist(self.inlinks)

    @property
    def degree_dist_out(self):
        return self.degree_dist(self.outlinks)

    @property
    def adj_list_in(self):
        adj_list = list()
        for y in range(0, len(self.matrix[:, 0])):
            adj_list.append(list(np.nonzero(self.matrix[y])[1]))
        return adj_list

    @property
    def adj_list_out(self):
        adj_list = list()
        for y in range(0, len(self.matrix[:, 0])):
            adj_list.append(list(np.nonzero(self.matrix[:,y])[0]))
        return adj_list

    def pagerank_iter(self, t):
        self.iters += 1
        max_diff = 0
        n = len(self.pr)
        t_by_n = t / n

        for i in range(0, len(self.pr)):
            new_pr = \
                t_by_n + (1 - t) * \
                sum([float(self.pr[j])/len(self.adj_list_out[j]) for j in self.adj_list_in[i]])
            max_diff = max(max_diff, abs(self.pr[i] - new_pr))
            self.pr[i] = new_pr
        return max_diff
