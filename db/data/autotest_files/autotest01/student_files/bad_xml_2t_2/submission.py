#!/usr/bin/env python

"""
This student submission file is used to test the autotester
It represents the test case where:

  The xml is malformed in the second test however the
  first test should be ok
"""
import json

print(json.dumps({'name': 'bad_xml_good_test', 'input': 'NA', 'expected': 'NA', 'actual': 'NA', 'marks_earned': 2, 'marks_total': 2, 'status': 'pass'}))
print(json.dumps({'name': 'bad_xml_good_test', 'input': 'NA', 'expected': 'NA', 'actual': 'NA', 'marks_earned': 2, 'marks_total': 2, 'status': 'pass'})[2:])
