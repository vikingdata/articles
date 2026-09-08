
* [basic gates](#b)
* [truth tables](#t)

## <a name=b></a>basic gates

| Gate Name & Expression | Universal? | Truth Table Inputs (A, B) & Output (Y) |
|---|---|---|
| NOT Y = Ā | No | A=0 → Y=1A=1 → Y=0 |
| AND Y = A ⋅ B | No | 0, 0 → 00, 1 → 01, 0 → 01, 1 → 1 |
| OR Y = A + B | No | 0, 0 → 00, 1 → 11, 0 → 11, 1 → 1 |
| NAND $Y = \overline{A \cdot B}$ | Yes | 0, 0 → 10, 1 → 11, 0 → 11, 1 → 0 |
| NOR $Y = \overline{A + B}$ | Yes | 0, 0 → 10, 1 → 01, 0 → 01, 1 → 0 |
| XOR $Y = A \oplus B$ | No | 0, 0 → 00, 1 → 11, 0 → 11, 1 → 0 |
| XNOR $Y = \overline{A \oplus B}$ | No | 0, 0 → 10, 1 → 01, 0 → 01, 1 → 1 |

* NOTE -- opposite of value.
* AND — True only when all inputs are true.
* OR — True when at least one input is true.
* NAND — The opposite of AND; false only when all inputs are true.
* NOR — The opposite of OR; true only when all inputs are false.
* XOR — True when the inputs are different.
* XNOR — True when the inputs are the same.

## <a name=t></a>Gate truth tables for 2, 3, and 4 input

Basically 2^(no of inputs) when calculating possible combnations of a gate.
Such as
There are 16 variables for a 4-input OR gate.

The total number of possible combinations depends on the number of inputs the gate has.
### The Equation
$$C = 2^n$$

* $C$ = Total number of possible input combinations
* $n$ = Number of inputs to the gate
* $2$ = Represents the two possible states for each input (Binary: 0 or 1)


### 2 gates (4 combinations)
| Inputs (A, B) | AND | OR | NAND | NOR | XOR | XNOR |
|---|---|---|---|---|---|---|
| 0, 0 | 0 | 0 | 1 | 1 | 0 | 1 |
| 0, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 1 | 1 | 1 | 0 | 0 | 0 | 1 |

------------------------------
### 3-Input Gates (All 8 Combinations)

| Inputs (A, B, C) | AND | OR | NAND | NOR | XOR (Odd 1s) | XNOR (Even 1s) |
|---|---|---|---|---|---|---|
| 0, 0, 0 | 0 | 0 | 1 | 1 | 0 | 1 |
| 0, 0, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 0, 1, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 0, 1, 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 0, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 0, 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 1, 0 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 1, 1 | 1 | 1 | 0 | 0 | 1 | 0 |

------------------------------
### 4-Input Gates (All 16 Combinations)

| Inputs (A, B, C, D) | AND | OR | NAND | NOR | XOR (Odd 1s) | XNOR (Even 1s) |
|---|---|---|---|---|---|---|
| 0, 0, 0, 0 | 0 | 0 | 1 | 1 | 0 | 1 |
| 0, 0, 0, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 0, 0, 1, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 0, 0, 1, 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 0, 1, 0, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 0, 1, 0, 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 0, 1, 1, 0 | 0 | 1 | 1 | 0 | 0 | 1 |
| 0, 1, 1, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 0, 0, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 0, 0, 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 0, 1, 0 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 0, 1, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 1, 0, 0 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1, 1, 0, 1 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 1, 1, 0 | 0 | 1 | 1 | 0 | 1 | 0 |
| 1, 1, 1, 1 | 1 | 1 | 0 | 0 | 0 | 1 |


## arithmetic, boolean, and meaning

| Logic Gate | Boolean representation                        | Meaning                    |
| ---------- | --------------------------------------------- | -------------------------- |
| AND    | $A \cdot B$                                 | Multiplication             |
| OR     | $A + B$                                     | Addition                   |
| NAND   | $\overline{A \cdot B}$                      | NOT(AND)                   |
| NOR    | $\overline{A + B}$                          | NOT(OR)                    |
| XOR    | $A \oplus B = \overline A B + A\overline B$ | Addition without carry |
| **XNOR**   | $A \odot B = AB + \overline A\overline B$   | Equality / NOT(XOR)        |

| Logic Gate | Meaning |
| ---------- | --------------------------------------------- |
| AND  | multiply: AB |
| OR   | add: A+B     |
| NOT  | complement: $\overline{A}$ |
| NAND | NOT multiply: $\overline{AB}$ |
| NOR  | NOT add: $\overline{A+B}$ |
| XOR  | different: $A\overline B+\overline A B$ |
| XNOR | same: $AB+\overline A\overline B$ |

For binary addition, the important ones are:

*  Sum = ${A\oplus B}$ 
*  Carry = ${A\cdot B}$ 

So an XOR gives the sum bit, while an AND gives the carry bit.




