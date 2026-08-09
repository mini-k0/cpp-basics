# C++ Basics - Day 1

Date: 2026-08-09

## What I learned

Today I startde learning basic C++ on Ubuntu.

I learned how to:

- Write a simple C++ program
- Compile C++ source code with 'g++'
- Run an executable file in Linux
- Understand the differnce between source code and an executable
- Declare and initialize variables
- Use basic date types
- Check the size of variables with 'sizeof'
- Check a variable's memory address with '&'
- convert between data types
- Understand integer division

---

# Detailed Notes

## 1. Compile and run a C++ program

Source code.

'''cpp
#include <iostream>

int main()
{
    std::cout << "Hello, Ubuntu!" << std::endl;
    return 0;
}

Compile:

'''bash
g++ main.cpp -o hello
'''

Run:

'''bash
./hello
'''

'main.cpp' is the source code.
'hello' is the executable created after compilation.
If I change 'main.cpp', the executable does not change automatically change.

I need to compile again:

'''bash
g++ main.cpp -o hello
'''

## 2. Variables

Example:

'''cpp
int age = 20;
'''

Meaning:

- 'int' = data type.
- 'age' = variable name.
- '20' = stored value.

A variable uses memmory while the program is running.

## 3. Basic Data Types

I used these basic types:

'''cpp
int age = 20;
double voltage = 3.3;
char grade = 'A';
bool power = true;
'''

In my current environment, 'sizeof()' showed:

- 'int' = 4 bytes.
- 'double' = 8 bytes.
- 'char' = 1 byte.
- 'bool' = 1 byte:

 The exact size of some types can depend on the system and compiler.

 ## 4. Memory adress

 Example:

 '''cpp
 std::cout << &age << std::endl;
'''

'&age' gives the memory address of the variable.
The address can change when the program is executed again.
This helped me understand that a variable has both:

- a value
- a location in memory

## 5. bool values

Example:

'''cpp
bool power = true;
'''

By default:

'''cpp
std::cout << power;
'''

prints:

'''text
1
'''

because 'true' is displayed as '1'.

Using:
'''cpp
std::cout << std::boolalpha;

makes it dispay:

'''text
true
'''

## 6. Type conversion

Example:

'''cpp
double value = 3.9;
int number = static_cast<int>(value);
'''

Result:

'''text
3
'''

When converting a floating-point value to an integer, the decimal part is discarded.

Example:

'''text
3.9 -> 3
-3.9 -> -3
'''

This is not normal rounding.

## 7. Integer division

Example:

'''cpp
int a = 5;
int b = 2;
'''

'a/b' gives '2' because both values are integers.

'''cpp
static_cast<double>(a)/b
'''

gives '2,5'.

## 8. Git and  Linux setup

I also startde organizing my C++ learning with Git.

Current project:

'''text
cpp-basics/
--.gitignere
--main.cpp
--examples/ ---05_integer_division.cpp
--notes/
'''

Iinitalized the repository with:

'''bash
git init
'''

and changed the branch name to:

'''bash
git branch -M main
'''

I also creatde a '.gitignore' so compiled files such as 'hello' are not trecked.