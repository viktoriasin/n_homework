import pytest
from hm3 import sum_diag, sum_diag_1, sum_of_digit, fib_sum, make_dict

def test_sum_diag():
    assert sum_diag([[0,0,0],[0,0,0],[0,0,0]]) == 0
    assert sum_diag([[1,0,0],[0,1,0],[0,1,1]]) == 3
    assert sum_diag([[-1,0,0],[0,10,0],[0,0,5]]) == 14
    assert sum_diag([[1,20,3],[-1,8,0],[3,4,6]]) == 15

def test_sum_diag_1():
    assert sum_diag_1([[0,0,0],[0,0,0],[0,0,0]]) == 0
    assert sum_diag_1([[1,0,0],[0,1,0],[0,1,1]]) == 3
    assert sum_diag_1([[-1,0,0],[0,10,0],[0,0,5]]) == 14
    assert sum_diag_1([[1,20,3],[-1,8,0],[3,4,6]]) == 15

def test_sum_of_digit():
    assert sum_of_digit([1,2,'a','v','123d','2','1']) == 10
    assert sum_of_digit([-1,2,'a','v','123d','-2','1']) == 10
    assert sum_of_digit(['-1','2','a','v','123d','-2','1']) == 10

def test_fib_sum():
    assert fib_sum(4) == 7
    assert fib_sum(5) == 12
    assert fib_sum(1) == 1

def test_make_dict():
    assert make_dict( ['2018-01-01', 'yandex', 'cpc', 100, 200, 300, 'kkk', 'sdfsdf']) == {'2018-01-01': {'yandex': {'cpc': 100}}}
    assert make_dict( ['2018-01-01', 'yandex', 'cpc', 100, 200, 300, 'kkk', 'sdfsdf',23424,234234,'sddfsdgf','sdfsdf']) == {'2018-01-01': {'yandex': {'cpc': {100: {200: {300: {'kkk': 'sdfsdf'}}}}}}}