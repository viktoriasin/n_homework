def sum_diag(data, count = 0):
    '''Возвращает сумму элементов по диагонали, используя рекурсию'''
    if count == len(data):
        return 0
    return data[count][count] + sum_diag(data, count + 1)

def sum_diag_1(data):
    '''Возвращает сумму элементов по диагонали, используя генераторы'''
    return sum(data[x][x] for x in range(len(data)))

def sum_of_digit(data):
    '''Сумма квадратов элементов списка со строками, используя метод isdigit() и функцию isinstance().'''
    #функция isdigit() не работает с отрицательными числами поэтому добавляем replace
    return sum(int(x) * int(x) for x in data if isinstance(x,int) or (isinstance(x,str) and x.replace('-','').isdigit()))

def fib_sum(n):
    '''реализация подсчета суммы n чисел Фибоначчи'''
    sum_ = 0
    f1, f2 = 0 , 1
    for i in range(n):
        sum_ += f2
        f1, f2 = f2, f2 + f1
    return sum_

def make_dict(lst):
    '''Преобразует произвольный список в словарь, используя рекурсию'''
    if len(lst) == 1:
        return lst[0]
    value = make_dict(lst[1:])
    d = {}
    d[lst[0]] = value
    return d