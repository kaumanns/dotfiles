#!/bin/python
from subprocess import check_output

def get_pass(pass_entry):
    return check_output("pass "+pass_entry, shell=True).rstrip()
