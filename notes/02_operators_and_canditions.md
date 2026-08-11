# Day 2 - Operators, Input, and Conditions

## 1. Arithmetic Operators

C++ provides arithmetic operators for basic calculations.

```cpp
int a = 10;
int b = 3;

std::cout << a + b << std::endl;
std::cout << a - b << std::endl;
std::cout << a * b << std::endl;
std::cout << a / b << std::endl;
std::cout << a % b << std::endl;
```

Main arithmetic operators:

- `+` : addition
- `-` : subtraction
- `*` : multiplication
- `/` : division
- `%` : remainder

Example:

```cpp
10 % 3
```

The result is `1` because the remainder of `10 / 3` is `1`.
The `%` operator is used with integer values.

---

## 2. Operator Precedence

C++ follows an order of operations.

For the operators covered today, the basic order is:

1. `( )`
2. `*`, `/`, `%`
3. `+`, `-`

Example:

```cpp
int result1 = 2 + 3 * 4;
int result2 = (2 + 3) * 4;
```

Results:

```text
result1 = 14
result2 = 20
```

Parentheses can be used to make the intended calculation order clear.

---

## 3. User Input with std::cin

`std::cin` receives input from the user.

```cpp
int age;

std::cout << "Enter your age: ";
std::cin >> age;
```

`std::cout` sends data to the screen.

```cpp
std::cout << age;
```

A simple way to remember them:

```text
cout << output
cin >> input
```

---

## 4. Simple Calculator

Two values can be received from the user and used in calculations.

```cpp
int a;
int b;

std::cin >> a;
std::cin >> b;

std::cout << a + b << std::endl;
std::cout << a - b << std::endl;
std::cout << a * b << std::endl;
std::cout << a / b << std::endl;
std::cout << a % b << std::endl;
```

When both variables are integers, integer division is performed.

For example:

```cpp
5 / 2
```

produces:

```text
2
```

not `2.5`.

---

## 5. Comparison Operators

Comparison operators compare two values and produce a Boolean result.

```text
==  equal to
!=  not equal to
>   greater than
<   less than
>=  greater than or equal to
<=  less than or equal to
```

Example:

```cpp
int a = 10;
int b = 3;

bool result = (a > b);
```

`result` becomes `true`.

It is important to distinguish assignment from comparison:

```cpp
a = b;
```

assigns the value of `b` to `a`.

```cpp
a == b
```

checks whether `a` and `b` are equal.

---

## 6. if Statement

An `if` statement executes code only when its condition is true.

```cpp
if (a > b)
{
    std::cout << "a is greater than b." << std::endl;
}
```

The condition:

```cpp
a > b
```

produces either `true` or `false`.

If it is `true`, the code inside the braces is executed.

---

## 7. if and else

`else` runs when the `if` condition is false.

```cpp
if (a > b)
{
    std::cout << "a is greater than b." << std::endl;
}
else
{
    std::cout << "a is not greater than b." << std::endl;
}
```

The `else` block does not have its own condition.

It simply means:

> If the previous condition is false, do this instead.

---

## 8. else if

`else if` allows a program to check another condition.

```cpp
if (a > b)
{
    std::cout << "a is greater than b." << std::endl;
}
else if (a < b)
{
    std::cout << "a is less than b." << std::endl;
}
else
{
    std::cout << "a and b are equal." << std::endl;
}
```

The program checks the conditions from top to bottom.

---

## 9. Logical Operators

Logical operators combine or modify Boolean conditions.

### AND - `&&`

Both conditions must be true.

```cpp
if (age >= 18 && student)
{
    std::cout << "Adult student" << std::endl;
}
```

Truth table:

```text
true && true -> true
true && false -> false
false && true -> false
false && false -> false
```

### OR - `||`

At least one condition must be true.

```cpp
if (age < 13 || age >= 65)
{
    std::cout << "Special discount" << std::endl;
}
```

Truth table:

```text
true || true -> true
true || false -> true
false || true -> true
false || false -> false
```

### NOT - `!`

`!` reverses a Boolean value.

```text
!true -> false
!false -> true
```

Example:

```cpp
if (!raining)
{
    std::cout << "You do not need an umbrella." << std::endl;
}
```

---

## 10. Combining Conditions

A condition can contain several logical expressions.

Example:

```cpp
if (age >= 18 && hasTicket && !banned)
{
    std::cout << "Entry allowed." << std::endl;
}
```

This means that:

1. the person must be at least 18,
2. the person must have a ticket,
3. the person must not be banned.

All three conditions must be true.

---

## 11. Nested if Statements

An `if` statement can be placed inside another `if` statement.

```cpp
if (age >= 18)
{
    if (hasTicket)
    {
        std::cout << "Entry allowed." << std::endl;
    }
    else
    {
        std::cout << "You need a ticket." << std::endl;
    }
}
else
{
    std::cout << "You are too young." << std::endl;
}
```

The inner condition is checked only when the outer condition is true.

A combined condition is useful when only the final result matters:

```cpp
if (age >= 18 && hasTicket)
```

A nested `if` is useful when different reasons or different stages of a decision need to be handled separately.

---

## 12. What I Learned Today

Today I learned how a program can receive data, calculate values, compare them, and make decisions.

The basic flow is:

```text
Input
  ↓
Store values in variables
  ↓
Calculate or compare
  ↓
Evaluate conditions
  ↓
Choose which code to execute
  ↓
Output
```

Topics completed:

- Arithmetic operators
- Remainder operator `%`
- Operator precedence
- `std::cin`
- Comparison operators
- `if`
- `else`
- `else if`
- Logical AND `&&`
- Logical OR `||`
- Logical NOT `!`
- Combining conditions
- Nested `if` statements

Next topic:

- `while` loops