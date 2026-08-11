# Day 3 - While Loops and Loop Control

## 1. Basic while Loop

A `while` loop repeats a block of code while its condition is true.

```cpp
int number = 1;

while (number <= 5)
{
    std::cout << number << std::endl;
    number++;
}
```

The output is:

```text
1
2
3
4
5
```

The loop checks the condition before each repetition.

When `number` becomes `6`, the condition:

```cpp
number <= 5
```

becomes false, so the loop ends.

---

## 2. Infinite Loops

A loop can continue forever if its condition never becomes false.

For example:

```cpp
int number = 1;

while (number <= 5)
{
    std::cout << number << std::endl;
}
```

Because `number` never changes, the condition always remains true.

A changing value such as:

```cpp
number++;
```

can allow the condition to eventually become false.

`Ctrl + C` can be used in the terminal to stop a running program.

---

## 3. Increment and Decrement

The increment operator increases a value by 1.

```cpp
number++;
```

This is equivalent to:

```cpp
number = number + 1;
```

The decrement operator decreases a value by 1.

```cpp
number--;
```

This is equivalent to:

```cpp
number = number - 1;
```

---

## 4. while Loop with User Input

A user can decide how many times a loop runs.

```cpp
int limit;
int number = 1;

std::cout << "Enter a number: ";
std::cin >> limit;

while (number <= limit)
{
    std::cout << number << std::endl;
    number++;
}
```

The three important parts are:

- starting value
- condition
- change of value

In this example:

```text
Start: number = 1
Condition: number <= limit
Change: number++
```

---

## 5. Accumulating Values

A loop can be used to calculate a running total.

```cpp
int number = 1;
int sum = 0;

while (number <= limit)
{
    sum = sum + number;
    number++;
}
```

For example, if `limit` is `5`:

```text
0 + 1 = 1
1 + 2 = 3
3 + 3 = 6
6 + 4 = 10
10 + 5 = 15
```

The final value of `sum` is `15`.

---

## 6. Combining while and if

A condition can be checked during every repetition.

```cpp
while (number <= limit)
{
    if (number % 2 == 0)
    {
        std::cout << number << std::endl;
    }

    number++;
}
```

The condition:

```cpp
number % 2 == 0
```

checks whether the current number is even.

This combines repetition with decision making.

---

## 7. Summing Even Numbers

A loop and an `if` statement can also be used together to accumulate only selected values.

```cpp
while (number <= limit)
{
    if (number % 2 == 0)
    {
        sum = sum + number;
    }

    number++;
}
```

If `limit` is `10`, the program calculates:

```text
2 + 4 + 6 + 8 + 10 = 30
```

---

## 8. Repeating User Input

A loop can continue until the user enters a special value.

```cpp
std::cin >> number;

while (number != 0)
{
    std::cout << "You entered: " << number << std::endl;

    std::cin >> number;
}
```

Here, `0` acts as a signal to stop the loop.

---

## 9. do while Loop

A `do while` loop executes its body first and checks the condition afterward.

```cpp
do
{
    std::cout << "Enter a number: ";
    std::cin >> number;
}
while (number != 0);
```

A normal `while` loop may execute zero times.

A `do while` loop always executes at least once.

The semicolon after the `while` condition is required.

---

## 10. break

`break` immediately exits a loop.

```cpp
while (true)
{
    std::cin >> number;

    if (number == 0)
    {
        break;
    }
}
```

`while (true)` creates a loop whose condition is always true.

The `break` statement provides a way to exit that loop.

---

## 11. continue

`continue` skips the rest of the current repetition and starts the next one.

```cpp
if (number < 0)
{
    continue;
}
```

The difference is:

```text
break -> exit the loop
continue -> skip the current iteration
```

---

## 12. Countdown

A loop can decrease a value instead of increasing it.

```cpp
int number = 5;

while (number > 0)
{
    std::cout << number << std::endl;
    number--;
}

std::cout << "Go!" << std::endl;
```

The output is:

```text
5
4
3
2
1
Go!
```

---

## 13. Password Input Loop

A loop can repeatedly ask for input until the correct value is entered.

```cpp
while (password != 1234)
{
    std::cout << "Wrong password. Try again: ";
    std::cin >> password;
}
```

This is only a practice example. Real passwords should not be stored directly in source code like this.

---

## 14. Limiting the Number of Attempts

A counter can control how many times a loop is allowed to run.

```cpp
int attempts = 0;

while (attempts < 3)
{
    std::cout << "Enter password: ";
    std::cin >> password;

    if (password == 1234)
    {
        std::cout << "Access granted." << std::endl;
        break;
    }

    attempts++;

    std::cout << "Wrong password." << std::endl;
}
```

The variable `attempts` counts failed attempts.

The loop continues while:

```cpp
attempts < 3
```

is true.

If the correct password is entered, `break` exits the loop immediately.

---

## 15. What I Learned Today

Today I learned how loops allow a program to repeat operations automatically.

I also learned how loops can work together with user input, conditions, and variables.

The basic idea of a loop is:

```text
Start
  ↓
Check condition
  ↓
Run code
  ↓
Change a value
  ↓
Check condition again
  ↓
Repeat or stop
```

Topics completed:

- `while` loops
- Infinite loops
- Increment `++`
- Decrement `--`
- User input inside loops
- Accumulating values
- Combining `while` and `if`
- `do while`
- `break`
- `continue`
- Countdown loops
- Repeated input
- Attempt counters

Next topic:

- `for` loops