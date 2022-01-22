````python
# Range and For
for index in range(6):
    print(index)
# Range function is used generate a sequence of integers
index = range(10, -1, -1) # start, stop and step, stops at 0 not including -1
# set class provides a mapping of unique immutable elements
# One use of set is to remove duplicate elements
dup_list = ('c', 'd', 'c', 'e')
beta = set(dup_list)
uniq_list = list(beta) 
# dict class is an associative array of keys and values. keys must be unique immutable objects
dict_syn = {'k1': 'v1', 'k2': 'v2'}
dict_syn = dict(k1='v1', k2='v2')
dict_syn['k3'] = 'v3'  # adding new key value
del(dict_syn['k3'])  # delete key value
print(dict_syn.keys()) # prints all keys
print(dict_syn.values()) # prints all values
# User Input
name = input('Name :')
# Functions
* A function is a piece of code, capable of performing a similar task repeatedly.
* It is defined using **def** keyword in python.
def <function_name>(<parameter1>, <parameter2>, ...):
     'Function documentation'
     function_body
     return <value>  
* Parameters, return expression and documentation string are optional.
def square(n):
    "Returns Square of a given number"
    return n**2

print(square.__doc__)   //prints the function documentation string
* 4 types of arguments
* Required Arguments: non-keyword arguments
def showname(name, age)

showname("Jack", 40)  // name="Jack", age=40
showname(40, "Jack")  // name=40, age="Jack"
* Keyword Arguments: identified by paramater names
def showname(name, age)

showname(age=40, name="Jack")
* Default Arguments: Assumes a default argument, if an arg is not passsed.
def showname(name, age=50)

showname("Jack")              // name="Jack", age=50
showname(age=40,"Jack")       // name="Jack", age=40
showname(name="Jack", age=40) // name="Jack", age=40
showname(name="Jack", 40)   // Python does not allow passing non-keyword after keyword arg. This will fail.
* Variable Length Arguments: Function preocessed with more arguments than specified while defining the function
def showname(name, *vartuple, **vardict)
# *vartuple = Variable non keyword argument which will be a tuple. Denoted by *
# **vardict = Variable keyword argument which will be a dictionary. Denoted by **
showname("Jack")                              // name="Jack"
showname("Jack", 35, 'M', 'Kansas')           // name="Jack", *vartuple=(35, 'M', 'Kansas')
showname("Jack", 35, city='Kansas', sex='M')  // name="Jack", *vartuple=(35), **vardict={city='Kansas', sex='M'}
# An Iterator is an object, which allows a programmer to traverse through all the elements of a collection, regardless of its specific implementation.
x = [6, 3, 1]
s = iter(x)            
print(next(s))      # -> 6
# List Comprehensions -> Alternative to for loops.
* More concise, readable, efficient and mimic functional programming style.
* Used to: Apply a method to all or specific elements of a list, and Filter elements of a list satisfying specific criteria.
x = [6, 3, 1]
y = [ i**2 for i in x ]   # List Comprehension expression
print(y)              # -> [36, 9, 1] 
* Filter positive numbers (using for and if)
vec = [-4, -2, 0, 2, 4]
pos_elm = [x for x in vec if x >= 0]  # Can be read as for every elem x in vec, filter x if x is greater than or equal to 0
print(pos_elm)         # -> [0, 2, 4]
* Applying a method to a list
def add10(x):
    return x + 10
    
n = [34, 56, 75, 3]
mod_n = [ add10(num) for num in n]
print(mod_n)
# A Generator is a function that produces a sequence of results instead of a single value
def arithmatic_series(a, r):
    while a < 50:
        yield a  # yield is used in place of return which suspends processing
        a += r

s = arithmatic_series(3, 10)
# Execution of further 'arithmetic series' can be resumed only by calling nextfunction again on generator 's'
print(s)   //Generator #output=3
print(next(s))  //Generator starts execution  # output=13
print(next(s))  //resumed # output=23
# A Generator expresions are generator versions of list comprehensions. They return a generator instead of a list.
x = [6, 3, 1]
g = (i**2 for i in x)  # generator expression
print(next(g))         # -> 36
# Dictionary Comprehensions -> takes the form {key: value for (key, value) in iterable}
myDict = {x: x**2 for x in [1,2,3,4,5]} 
print (myDict)    # Output {1: 1, 2: 4, 3: 9, 4: 16, 5: 25}
# Calculate the frequency of each identified unique word in the list
words = ['Hello', 'Hi', 'Hello']
freq = { w:words.count(w) for w in words }
print(freq)    # Output {'Hello': 2, 'Hi': 1}
Create the dictionary frequent_words, which filter words having frequency greater than one
words = ['Hello', 'Hi', 'Hello']
freq = { w:words.count(w) for w in words if words.count(w) > 1 }
print(freq)   # Output {'Hello': 2}
# Defining Classes
* Syntax
class <ClassName>(<parent1>, ... ):
    class_body
# Creating Objects
* An object is created by calling the class name followed by a pair of parenthesis.
class Person:             
    pass                    
p1 = Person()      # Creating the object 'p1'
print(p1)          # -> '<__main__.Person object at 0x0A...>' # tells you what class it belongs to and hints on memory address it is referenced to.
# initializer method -> __init__ 
*  defined inside the class and called by default, during an object creation.
* It also takes self as the first argument, which refers to the current object.
class Person:
    def __init__(self, fname, lname):
        self.fname = fname
        self.lname = lname
p1 = Person('George', 'Smith')   
print(p1.fname, '-', p1.lname)           # -> 'George - Smith'
# Documenting a Class
* Each class or a method definition can have an optional first line, known as docstring.
class Person:
    'Represents a person.'
# Inheritance
* Inheritance describes is a kind of relationship between two or more classes, abstracting common details into super class and storing specific ones in the subclass.
* To create a child class, specify the parent class name inside the pair of parenthesis, followed by it's name. 
class Child(Parent):  
   pass
* Every child class inherits all the behaviours exhibited by their parent class.
* In Python, every class uses inheritance and is inherited from **object** by default.
class MySubClass(object):     # object is known as parent or super class.
    pass   
# Inheritance in Action
class Person:
    def __init__(self, fname, lname):
        self.fname = fname
        self.lname = lname
class Employee(Person):
    all_employees = []
    def __init__(self, fname, lname, empid):
        Person.__init__(self, fname, lname)  # Employee class utilizes __init __ method of the parent class Person to create its object.
        self.empid = empid
        Employee.all_employees.append(self)

e1 = Employee('Jack', 'simmons', 456342) 
print(e1.fname, '-', e1.empid)   # Output -> Jack - 456342  
# Polymorphism
* Polymorphism allows a subclass to override or change a specific behavior, exhibited by the parent class
class Employee(Person):
    all_employees = EmployeesList ()
    def __init__(self, fname, lname, empid):
        Person.__init__(self, fname, lname)
        self.empid = empid
        Employee.all_employees.append(self)
    def getSalary(self):
        return 'You get Monthly salary.'
    def getBonus(self):
        return 'You are eligible for Bonus.'
* Definition of ContractEmployee class derived from Employee. It overrides functionality of getSalary and getBonus methods found in it's parent class Employee.
class ContractEmployee(Employee):
   def getSalary(self):
        return 'You will not get Salary from Organization.'
    def getBonus(self):
        return 'You are not eligible for Bonus.'

e1 = Employee('Jack', 'simmons', 456342)
e2 = ContractEmployee('John', 'williams', 123656)
print(e1.getBonus())    # Output - You are eligible for Bonus.
print(e2.getBonus())    # Output - You are not eligible for Bonus.
# Abstraction
* Abstraction means working with something you know how to use without knowing how it works internally.
* It is hiding the defaults and sharing only necessary information.
# Encapsulation
* Encapsulation allows binding data and associated methods together in a unit i.e class.
* Bringing related data and methods inside a class to avoid misuse outside. 
* These principles together allows a programmer to define an interface for applications, i.e. to define all tasks the program is capable to execute and their respective input and output data.
* A good example is a television set. We don’t need to know the inner workings of a TV, in order to use it. All we need to know is how to use the remote control (i.e the interface for the user to interact with the TV).
# Abstracting Data
* Direct access to data can be restricted by making required attributes or methods private, **just by prefixing it's name with one or two underscores.**
* An attribute or a method starting with:
+ **no underscores** is a **public** one.
+ **a single underscore** is **private**, however, still accessible from outside.
+ **double underscores** is **strongly private** and not accessible from outside.
# Abstraction and Encapsulation Example
* **empid** attribute of Employee class is made private and is accessible outside the class only using the method **getEmpid**.
class Employee(Person):
    all_employees = EmployeesList()
    def __init__(self, fname, lname, empid):
        Person.__init__(self, fname, lname)
        self.__empid = empid
        Employee.all_employees.append(self)
    def getEmpid(self):
        return self.__empid

e1 = Employee('Jack', 'simmons', 456342)
print(e1.fname, e1.lname)         # Output -> Jack simmons
print(e1.getEmpid())              # Output -> 456342
print(e1.__empid)                 # Output -> AttributeError: Employee instance has no attribute '__empid'
# Exceptions
* Python allows a programmer to handle such exceptions using **try ... except** clauses, thus avoiding the program to crash.
* Some of the python expressions, though written correctly in syntax, result in error during execution. **Such scenarios have to be handled.**
* In Python, every error message has two parts. The first part tells what type of exception it is and second part explains the details of error.
# Handling Exception
* A try block is followed by one or more except clauses.
* The code to be handled is written inside try clause and the code to be executed when an exception occurs is written inside except clause.
try:
    a = pow(2, 4)
    print("Value of 'a' :", a)
    b = pow(2, 'hello')   # results in exception
    print("Value of 'b' :", b)
except TypeError as e:
    print('oops!!!')
print('Out of try ... except.')
Output -> Value of 'a' : 16 --> oops!!! --> Out of try ... except.
# Raising Exceptions
* **raise** keyword is used when a programmer wants a specific exception to occur.
try:
    a = 2; b = 'hello'
    if not (isinstance(a, int)
            and isinstance(b, int)):
        raise TypeError('Two inputs must be integers.')
    c = a**b
except TypeError as e:
    print(e)
# User Defined Exception Functions
* Python also allows a programmer to create custom exceptions, derived from base Exception class.
class CustomError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return str(self.value)
        
try:
    a = 2; b = 'hello'
    if not (isinstance(a, int)
            and isinstance(b, int)):
        raise CustomError('Two inputs must be integers.') # CustomError is raised in above example, instead of TypeError.
   c = a**b
except CustomError as e:
    print(e)
# Using 'finally' clause
* **finally** clause is an optional one that can be used with try ... except clauses.
* All the statements under finally clause are executed irrespective of exception occurrence.
def divide(a,b):
    try:
        result = a / b
        return result
    except ZeroDivisionError:
        print("Dividing by Zero.")
    finally:
        print("In finally clause.")    # Statements inside finally clause are ALWAYS executed before the return back 
# Using 'else' clause
* **else** clause is also an optional clause with try ... except clauses.
* Statements under else clause are executed **only when no exception occurs in try clause**.
try:
    a = 14 / 7
except ZeroDivisionError:
    print('oops!!!')
else:
    print('First ELSE')
try:
    a = 14 / 0
except ZeroDivisionError:
    print('oops!!!')
else:
    print('Second ELSE')
Output: First ELSE --> oops!!!
# Module
* Any file containing logically organized Python code can be used as a module.
* A module generally contains **any of the defined functions, classes and variables**. A module can also include executable code.
* Any Python source file can be used as a module by using an import statement in some other Python source file.
# Packages
* A package is a collection of modules present in a folder. 
* The name of the package is the name of the folder itself. 
* A package generally contains an empty file named **__init__.py** in the same folder, which is required to treat the folder as a package.
# Import Modules
import math         # Recommended method of importing a module
import math as m
from math import pi, tan
from math import pi as pie, tan as tangent
# Working with Files
* Data from an opened file can be read using any of the methods: **read, readline and readlines**.
* Data can be written to a file using either **write** or **writelines** method.
* A file **must be opened**, before it is used for reading or writing.
fp = open('temp.txt', 'r')   # opening ( operations 'r' & 'w')
content = fp.read()          # reading
fp.close()                   # closing
# read() -> Reads the entire contents of a file as bytes. 
# readline() -> Reads a single line at a time.
# readlines() -> Reads a all the line  & each line is stored as an element of a list.
# write() -> Writes a single string to output file.
# writelines() -> Writes multiple lines to output file & each string is stored as an element of a list. 
* Reading contents of file and storing as a dictionary
fp = open('emp_data.txt', 'r')
emps = fp.readlines()
# Preprocessing data
emps = [ emp.strip('\n') for emp in emps ]
emps = [ emp.split(';') for emp in emps ] 
header = emps.pop         # remove header record separately
emps = [ dict(zip(header, emp) for emp in emps ]   # header record is used to combine with data to form a dictionary

print(emps[:2])   # prints first 2 records

* Filtering data based on criteria
fil_emps = [emp['Emp_name'] for emp in emps if emp['Emp_work_location']=='HYD']
* Filtering data based on pattern
import re
pattern = re.compile(r'oracle', re.IGNORECASE)  # Regular Expression
oracle_emps = [emp['Emp_name'] for emp in emps if pattern.search(emp['Emp_skillset'])]
* Filter and Sort data in ascending order
fil_emps = [emp for emp in emps if emp['Emp_designation']=='ASE']
fil_emps = sorted(fil_emps, key=lambda k: k['Emp_name'])
print(emp['Emp_name'] for emp in fil_emps )
* Sorting all employees based on custom sorting criteria
order = {'ASE': 1, 'ITA': 2, 'AST': 3}
sorted_emp = sorted(emp, key=lambda k: order[k['designation']])
* Filter data and write into files
fil_emps = [emp for emp in emps if emp['Emp_Designation'] == 'ITA']
ofp = open(outputtext.txt, 'w')
keys = fil_emps[0].keys()  # Remove header from key name
for key in keys:
    ofp.write(key+"\t")
ofp.write("\n")
for emp in fil_emps:
    for key in keys:
        ofp.write(emp[key]+"\t")
    ofp.write("\n")
ofp.close()
# Regular Expressions
* Regex are useful to construct patterns that helps in filtering the text possessing the pattern.
* **re module** is used to deal with regex.
* **search** method takes pattern and text to scan  and returns a Match object. Return None if not found.
* Match object holds info on the nature of the match like **original input string, Regular expression used, location within the original string**
match = re.search(pattern, text)
start_index = match.start()  # start location of match
end_index = match.end()
regex = match.re.pattern()
print('Found "{}" pattern in "{}" from {} to {}'.format(st, text, start_index, end_index))
# Compiling Expressions
* In Python, its more efficient t compile the patterns that are frequently used.
* **compile** function of re module converts an expression string into a **RegexObject**.
patterns = ['this', 'that']
regexes = [re.compile(p) for p in patterns]
for regex in regexes:
    if regex.search(text):   # pattern is not required
        print('Match found')
* search method only returns the first matching occurrence.
# Finding Multiple Matches
* findall method returns all the substrings of the pattern without overlapping
pattern= 'ab'
for match in re.findall(pattern, text):
	print('match found - {}'.format(match))
# Grouping Matches
* Adding groups to a pattern enables us to isolate parts of the matching text, expanding those capabilities to create a parser.
* Groups are defined by enclosing patterns within parenthesis
text= 'This is some text -- with punctuations.'
for pattern in [r'^(\w+)',                  # word at the start of the string
				r'(\w+)\S*$',               # word at the end of the string with punctuation
				r'(\bt\w+)\W+(\w+)',        # word staring with 't' and the next word
				r'(\w+t)\b']:               # word ending with t
	regex = re.compile(pattern)
	match = regex.search(text)
	print(match.groups())                   # Output -> ('This',) ('punctuations',) ('text','with') ('text',)
# Naming Grouped Matches
* Accessing the groups with defined names
text= 'This is some text -- with punctuations.'
for pattern in [r'^(?P<first_word>\w+)',                  # word at the start of the string
				r'(?P<last_word>\w+)\S*$',                # word at the end of the string with punctuation
				r'(?P<t_word>\bt\w+)\W+(?P<other_word>\w+)',  # word staring with 't' and the next word
				r'(?P<ends_with_t>\w+t)\b']:              # word ending with t
	regex = re.compile(pattern)
	match = regex.search(text)
	print("Groups: ",match.groups())                 # Output -> ('This',) ('punctuations',) ('text','with') ('text',)
	print("Group Dictionary: ",match.groupdict())    # Output -> {'first_word':'This'} {'last_word': 'punctuations'} {'t_word':'text', 'other_word':'with'} {'ends_with_t':'text'}
# Data Handling
# Handling XML files
* **lxml** 3rd party module is a highly feature rich with ElementTree API and supports querying wthe xml content using XPATH.
* In the ElementTree API, an element acts like a list. The items of the list are the elements children.
* XML search is faster in lxml.
<?xml>
<employee>
	<skill name="Python"/>
</employee>
from lxml import etree
tree = etree.parse('sample.xml')
root = tree.getroot()  # gets doc root <?xml>
skills = tree.findall('//skill')  # gets all skill tags
for skill in skills:
	print("Skills: ", skill.attrib['name'])
# Adding new skill in the xml
skill = etree.SubElement(root, 'skill', attrib={'name':'PHP'})
# Handling HTML files
* **lxml** 3rd party module is used for parsing HTML files as well.
import urllib.request
from lxml import etree
def readURL(url):
	urlfile = urllib.request.urlopen(url)
	if urlfile.getcode() == 200:
		contents = urlfile.read()
		return contents
if __name__ == '__main__':
	url = 'http://xkcd.com'
	html = readURL(url)
# Data Serialization
* Process of converting **data types/objects** into **Transmittable/Storable** format is called Data Serialization.
* In python, **pickle and json** modules are used for Data Serialization.
* Serialized data can then be written to file/Socket/Pipe. From these it can be de-serialized and stored into a new Object.
json.dump(data, file, indent=2)  # serialized data is written to file with indentation using dump method
data_new = json.load(file)       # de-serialized data is written to new object using load method
# Database Connectivity
* **Python Database API (DB-API)** is a standard interface to interact with various databases.
* Different DB API’s are used for accessing different databases. Hence a programmer has to install DB API corresponding to the database one is working with.
* Working with a database includes the following steps:
	+ Importing the corresponding DB-API module.
	+ Acquiring a connection with the database.
	+ Executing SQL statements and stored procedures.
	+ Closing the connection
import sqlite3
# establishing  a database connection
con = sqlite3.connect('D:\\TEST.db')
# preparing a cursor object
cursor = con.cursor()
# preparing sql statements
sql1 = 'DROP TABLE IF EXISTS EMPLOYEE'
# closing the database connection
con.close()
# Inserting Data
* Single rows are inserted using **execute** and multiple rows using **executeMany** method of created cursor object.
# preparing sql statement
rec = (456789, 'Frodo', 45, 'M', 100000.00)
sql = '''
      INSERT INTO EMPLOYEE VALUES ( ?, ?, ?, ?, ?)
      '''
# executing sql statement using try ... except blocks
try:
    cursor.execute(sql, rec)
    con.commit()
except Exception as e:
    print("Error Message :", str(e))
    con.rollback()
# Fetching Data
* **fetchone**: It retrieves one record at a time in the form of a tuple.
* **fetchall**: It retrieves all fetched records at a point in the form of tuple of tuples.
# fetching the records
records = cursor.fetchall()
# Displaying the records
for record in records:
    print(record)
# Object Relational Mappers
* An object-relational mapper (ORM) is a library that automates the transfer of data stored in relational database tables into objects that are adopted in application code.
* ORMs offer a high-level abstraction upon a relational database, which permits a developer to write Python code rather than SQL to create, read, update and delete data and schemas in their database.
* Such an ability to write Python code instead of SQL speeds up web application development.
# Higher Order Functions
* A **Higher Order function** is a function, which is capable of doing any one of the following things:
+ It can be functioned as a **data** and be assigned to a variable.
+ It can accept any other **function as an argument**.
+ It can return a **function as its result**.
*The ability to build Higher order functions, **allows a programmer to create Closures, which in turn are used to create Decorators**.
# Function as a Data
def greet():
    return 'Hello Everyone!'
print(greet())
wish = greet        # 'greet' function assigned to variable 'wish'
print(type(wish))   # Output -> <type 'function'>
print(wish())       # Output -> Hello Everyone!
# Function as an Argument
def add(x, y):
    return x + y
def sub(x, y):
   return x - y
def prod(x, y):
    return x * y
def do(func, x, y):
   return func(x, y)
print(do(add, 12, 4))   # 'add' as arg # Output -> 16
print(do(sub, 12, 4))   # 'sub' as arg # Output -> 8
print(do(prod, 12, 4))  # 'prod' as arg # Output -> 48
# Returning a Function
def outer():
    def inner():
        s = 'Hello world!'
        return s            

    return inner()   

print(outer()) # Output -> Hello world!
* You can observe from the output that the **return value of 'outer' function is the return value of 'inner' function** i.e 'Hello world!'.

def outer():
    def inner():
        s = 'Hello world!'
        return s            

    return inner   # Removed '()' to return 'inner' function itself   

print(outer()) #returns 'inner' function  # Output -> <function inner at 0xxxxxx>
func = outer() 
print(type(func))     # Output -> <type 'function'>
print(func()) # calling 'inner' function  # Output -> Hello world!
* Parenthesis after the **inner** function are removed so that the **outer** function returns **inner function**.
# Closures
* A Closure is a **function returned by a higher order function**, whose return value depends on the data associated with the higher order function.
def multiple_of(x):
    def multiple(y):
        return x*y
    return multiple
c1 = multiple_of(5)  # 'c1' is a closure
c2 = multiple_of(6)  # 'c2' is a closure
print(c1(4)) # Output -> 5 * 4 = 20
print(c2(4)) # Output -> 6 * 4 = 24
* The first closure function, c1 binds the value 5 to argument x and when called with an argument 4, it executes the body of multiple function and returns the product of 5 and 4.
* Similarly c2 binds the value 6 to argument x and when called with argument 4 returns 24.
# Decorators
* Decorators are evolved from the concept of closures.
* A decorator function is a higher order function that takes a function as an argument and returns the inner function.
* A decorator is capable of adding extra functionality to an existing function, without altering it.
* The decorator function is prefixed with **@ symbol** and written above the function definition.
+ Shows the creation of closure function wish using the higher order function outer.
def outer(func):
    def inner():
        print("Accessing :", 
                  func.__name__)
        return func()
    return inner
def greet():
   print('Hello!')
wish = outer(greet)    # Output -> Accessing : greet
wish()                 # Output -> Hello!
    - wish is the closure function obtained by calling an outer function with the argument greet. When wish function is called, inner function gets executed.
+ The second one shows the creation of decorator function outer, which is used to decorate function greet.
def outer(func):
   def inner():
        print("Accessing :", 
                  func.__name__)
        return func()
    return inner
def greet():
   return 'Hello!'
greet = outer(greet) # decorating 'greet' # Output -> No Output as return is used instead of print 
greet()  # calling new 'greet'  # Output -> Accessing : greet
    - The function returned by outer is assigned to greet i.e the function name passed as argument to outer. This makes outer a decorator to greet.
+ Third one displays decorating the greet function with decorator function, outer, using @ symbol.
def outer(func):
    def inner():
        print("Accessing :", 
                func.__name__)
        return func()
    return inner
@outer               # This is same as **greet = outer(greet)**
def greet():
    return 'Hello!'
greet()          # Output -> Accessing : greet
# Descriptors
* Python descriptors allow a programmer to create managed attributes.
* In other object-oriented languages, you will find **getter and setter** methods to manage attributes.
* However, Python allows a programmer to manage the attributes simply with the attribute name, without losing their protection.
* This is achieved by defining a **descriptor class**, that implements any of **__get__, __set__, __delete__** methods.
class EmpNameDescriptor:
    def __get__(self, obj, owner):
        return self.__empname
    def __set__(self, obj, value):
        if not isinstance(value, str):
            raise TypeError("'empname' must be a string.")
        self.__empname = value
* The descriptor, EmpNameDescriptor is defined to manage empname attribute. It checks if the value of empname attribute is a string or not.
class EmpIdDescriptor:
    def __get__(self, obj, owner):
        return self.__empid
    def __set__(self, obj, value):
        if hasattr(obj, 'empid'):
            raise ValueError("'empid' is read only attribute")
        if not isinstance(value, int):
            raise TypeError("'empid' must be an integer.")
        self.__empid = value
* The descriptor, EmpIdDescriptor is defined to manage empid attribute.
class Employee:
    empid = EmpIdDescriptor()           
    empname = EmpNameDescriptor()       
    def __init__(self, emp_id, emp_name):
        self.empid = emp_id
        self.empname = emp_name
* Employee class is defined such that, it creates empid and empname attributes from descriptors EmpIdDescriptor and EmpNameDescriptor.
e1 = Employee(123456, 'John')
print(e1.empid, '-', e1.empname)  # Output -> '123456 - John'
e1.empid = 76347322     # Output -> ValueError: 'empid' is read only attribute
# Properties
* Descriptors can also be created using property() type.
+ Syntax:
property(fget=None, fset=None, fdel=None, doc=None)
- where,
    fget : attribute get method
    fset : attribute set method
    fdel – attribute delete method
    doc – docstring
class Employee:
    def __init__(self, emp_id, emp_name):
        self.empid = emp_id
        self.empname = emp_name
    def getEmpID(self):
        return self.__empid
    def setEmpID(self, value):
       if not isinstance(value, int):
            raise TypeError("'empid' must be an integer.")
        self.__empid = value
    empid = property(getEmpID, setEmpID)
# Property Decorators
* Descriptors can also be created with property decorators.
* While using property decorators, an attribute's get method will be same as its name and will be decorated with property.
* In a case of defining any set or delete methods, they will be decorated with respective setter and deleter methods.
class Employee:
    def __init__(self, emp_id, emp_name):
        self.empid = emp_id
        self.empname = emp_name
    @property
    def empid(self):
        return self.__empid
    @empid.setter
    def empid(self, value):
        if not isinstance(value, int):
            raise TypeError("'empid' must be an integer.")
        self.__empid = value
e1 = Employee(123456, 'John')
print(e1.empid, '-', e1.empname)    # Output -> '123456 - John'
# Introduction to Class and Static Methods
Based on the **scope**, functions/methods are of two types. They are:
* Class methods
* Static methods
# Class Methods
* A method defined inside a class is bound to its object, by default.
* However, if the method is bound to a Class, then it is known as **classmethod**.
class Circle(object):
    no_of_circles = 0
    def __init__(self, radius):
        self.__radius = radius
        Circle.no_of_circles += 1
    def getCirclesCount(self):
        return Circle.no_of_circles
c1 = Circle(3.5)
c2 = Circle(5.2)
c3 = Circle(4.8)
print(c1.getCirclesCount())       # -> 3
print(Circle.getCirclesCount(c3)) # -> 3
print(Circle.getCirclesCount())   # -> TypeError: getCirclesCount() missing 1 required positional argument: 'self'
class Circle(object):
    no_of_circles = 0
    def __init__(self, radius):
        self.__radius = radius
        Circle.no_of_circles += 1
    @classmethod
    def getCirclesCount(self):
        return Circle.no_of_circles
c1 = Circle(3.5)           
c2 = Circle(5.2)           
c3 = Circle(4.8)           
print(c1.getCirclesCount())       # -> 3
print(Circle.getCirclesCount())   # -> 3
# Static Method
* A method defined inside a class and not bound to either a class or an object is known as **Static** Method.
* Decorating a method using **@staticmethod** decorator makes it a static method.
def square(x):
        return x**2
class Circle(object):
    def __init__(self, radius):
        self.__radius = radius
    def area(self):
        return 3.14*square(self.__radius)
c1 = Circle(3.9)
print(c1.area())       # -> 47.7594
print(square(10))      # -> 100
* square function is not packaged properly and does not appear as integral part of class Circle.
class Circle(object):
    def __init__(self, radius):
        self.__radius = radius
    @staticmethod
    def square(x):
        return x**2
    def area(self):
        return 3.14*self.square(self.__radius)
c1 = Circle(3.9)
print(c1.area())  # -> 47.7594
print(square(10)) # -> NameError: name 'square' is not defined
* square method is no longer accessible from outside the class Circle.
* However, it is possible to access the static method using Class or the Object as shown below.
print(Circle.square(10)) # -> 100
print(c1.square(10))     # -> 100
# Abstract Base Classes
* An **Abstract Base Class** or **ABC** mandates the derived classes to implement specific methods from the base class.
* It is not possible to create an object from a defined ABC class.
* Creating objects of derived classes is possible only when derived classes override existing functionality of all abstract methods defined in an ABC class.
* In Python, an Abstract Base Class can be created using module abc.
from abc import ABC, abstractmethod
class Shape(ABC):
    @abstractmethod
    def area(self):
        pass
    @abstractmethod
    def perimeter(self):
        pass
* Abstract base class Shape is defined with two abstract methods area and perimeter.
class Circle(Shape):
    def __init__(self, radius):
        self.__radius = radius
    @staticmethod
    def square(x):
        return x**2
    def area(self):
        return 3.14*self.square(self.__radius)
    def perimeter(self):
        return 2*3.14*self.__radius
c1 = Circle(3.9)
print(c1.area())   # -> 47.7594
# Context Manager
* A Context Manager allows a programmer to perform required activities, automatically, while entering or exiting a Context.
* For example, opening a file, doing few file operations, and closing the file is manged using Context Manager as shown below.
with open('sample.txt', 'w') as fp:
    content = fp.read()
* The keyword **with** is used in Python to enable a context manager. It automatically takes care of closing the file.
import sqlite3
class DbConnect(object):
    def __init__(self, dbname):
        self.dbname = dbname
    def __enter__(self):
        self.dbConnection = sqlite3.connect(self.dbname)
        return self.dbConnection
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.dbConnection.close()
with DbConnect('TEST.db') as db:
    cursor = db.cursor()
    '''
   Few db operations
   ...
    '''
* Example
from contextlib import contextmanager
@contextmanager
def context():
    print('Entering Context')
    yield 
    print("Exiting Context")

with context():
    print('In Context')
# Output -> Entering Context -> In Context -> Exiting Context
# Coroutines
* A Coroutine is **generator** which is capable of constantly receiving input data, process input data and may or may not return any output.
* Coroutines are majorly used to build better **Data Processing Pipelines**.
* Similar to a generator, execution of a coroutine stops when it reaches **yield** statement.
* A Coroutine uses **send** method to send any input value, which is captured by yield expression.
def TokenIssuer():
    tokenId = 0
    while True:
        name = yield
        tokenId += 1
        print('Token number of', name, ':', tokenId)
t = TokenIssuer()
next(t)
t.send('George')  # -> Token number of George: 1
t.send('Rosy')    # -> Token number of Rosy: 2
* **TokenIssuer** is a coroutine function, which uses yield to accept name as input.
* Execution of coroutine function begins only when next is called on coroutine t.
* This results in the execution of all the statements till a yield statement is encountered.
* Further execution of function resumes when an input is passed using send, and processes all statements till next yield statement.
def TokenIssuer(tokenId=0):
    try:
       while True:
            name = yield
            tokenId += 1
            print('Token number of', name, ':', tokenId)
    except GeneratorExit:
        print('Last issued Token is :', tokenId)
t = TokenIssuer(100)
next(t)
t.send('George') # Token number of George: 101
t.send('Rosy')   # Token number of Rosy: 102
t.send('Smith')  # Token number of Smith: 103
t.close()        # Last issued Token is: 103
* The coroutine function TokenIssuer takes an argument, which is used to set a starting number for tokens.
* When coroutine t is closed, statements under GeneratorExit block are executed.
* Many programmers may forget that passing input to coroutine is possible only after the first next function call, which results in error.
* Such a scenario can be avoided using a decorator.
def coroutine_decorator(func):
    def wrapper(*args, **kwdargs):
        c = func(*args, **kwdargs)
        next(c)
        return c
    return wrapper
@coroutine_decorator
def TokenIssuer(tokenId=0):
    try:
        while True:
            name = yield
            tokenId += 1
            print('Token number of', name, ':', tokenId)
    except GeneratorExit:
        print('Last issued Token is :', tokenId)
t = TokenIssuer(100)
t.send('George')
t.send('Rosy')
t.send('Smith')
t.close()
* coroutine_decorator takes care of calling next on the created coroutine t.
def nameFeeder():
    while True:
        fname = yield
        print('First Name:', fname)
        lname = yield
        print('Last Name:', lname)

n = nameFeeder()
next(n)
n.send('George')
n.send('Williams')
n.send('John')
First Name: George
Last Name: Williams
First Name: John




````