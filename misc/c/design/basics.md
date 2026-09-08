
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



Basically 2^(no of inputs) when calculating possible combnations of a gate.
Such as
There are 16 variables for a 4-input OR gate.

The equation to find the total number of possible combinations (or rows) in a truth table depends entirely on the number of inputs the gate has.
## The Equation
$$C = 2^n$$ 

* $C$ = Total number of possible input combinations
* $n$ = Number of inputs to the gate
* $2$ = Represents the two possible states for each input (Binary: 0 or 1)


