
When using bits for a 2 bit circuit, each bit can be presented by two numbers.
Such as A = A1A10 where A1 is the second digit and A0 is the first digit. 
The first digit is 0 or 1.
The second digit is 0 or 1.
In the truth tables, when two numbers are added together,
the final value ranges from 00 to 11 with an overflow.

The two numbers A nd B and the result is the number C with or without a carry over
( the third digit).

Each number is represented as the following.

| Decimal  |Binary |
| -- | -- |
| 0    | 00 | 0 | 
|     1 | 01 |
|     2 | 10 |
|     3 | 11 |

When adding a digit, the poissble values are 0, 1, and 0 with a carry over to the next bit.

| digit 1 of number 1 | digit 1 of number 2| carry over | result of digit |
| --| -- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 0 |



To add two numbers together:
1. Add the first bit of each number together.


When added together, there may be a carry out. This is a half adder because there is no carry in.
If there was a carry in it would be a full adder. 

| A  | B  | A + B | Result (2-bit) | Carry Out |
| -- | -- | ----- | -------------- | --------- |
| 00 | 00 | 0 + 0 | 00   | 0   |
| 00 | 01 | 0 + 1 | 01   | 0   |
| 00 | 10 | 0 + 2 | 10   | 0   |
| 00 | 11 | 0 + 3 | 11   | 0   |
| 01 | 00 | 1 + 0 | 01   | 0   |
| 01 | 01 | 1 + 1 | 10   | 0   |
| 01 | 10 | 1 + 2 | 11   | 0   |
| 01 | 11 | 1 + 3 | 00   | 1   |
| 10 | 00 | 2 + 0 | 10   | 0   |
| 10 | 01 | 2 + 1 | 11   | 0   |
| 10 | 10 | 2 + 2 | 00   | 1   |
| 10 | 11 | 2 + 3 | 01   | 1   |
| 11 | 00 | 3 + 0 | 11   | 0   |
| 11 | 01 | 3 + 1 | 00   | 1   |
| 11 | 10 | 3 + 2 | 01   | 1   |
| 11 | 11 | 3 + 3 | 10   | 1   |
