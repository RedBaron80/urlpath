# -*- coding: utf-8 -*-

from .context import urlpath

import unittest


class AdvancedTestSuite(unittest.TestCase):
    """Advanced test cases."""

    def test_one_level(self):
        self.assertEqual(urlpath.getUrlPath('http://www.example.com/hello/'), 'hello')

if __name__ == '__main__':
    unittest.main()
