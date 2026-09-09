
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

When adding a two digits of any digit position,
the possible values are 0, 1, and 0 with a carry over to the next bit.

| digit 1 of number 1 | digit 1 of number 2| carry over | result of digit |
| --| -- | -- | -- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 0 |

Let C = A + b
* A = A1A0
* B = B1B0
* C = C1C0
* K = carry over from A + B

Then
* C0 = A0 XOR B0
* K = A0 AND B0
   * The secobnd bit of K is always 0, so only K0 matters. 
* C1 = A1 XOR B1 XOR K

If there was a carry in it would be a full adder. 

| A  | B  | A + B | Decimal | C | K0 (carry out) |
| -- | -- | ----- | -- | -------------- | --------- |
| 00 | 00 | 0 + 0 | 0 | 00   | 0   |
| 00 | 01 | 0 + 1 | 1 | 01   | 0   |
| 00 | 10 | 0 + 2 | 2 | 10   | 0   |
| 00 | 11 | 0 + 3 | 3 | 11   | 0   |
| 01 | 00 | 1 + 0 | 1 | 01   | 0   |
| 01 | 01 | 1 + 1 | 2 | 10   | 0   |
| 01 | 10 | 1 + 2 | 3 | 11   | 0   |
| 01 | 11 | 1 + 3 | 4 | 00   | 1   |
| 10 | 00 | 2 + 0 | 2 | 10   | 0   |
| 10 | 01 | 2 + 1 | 3 | 11   | 0   |
| 10 | 10 | 2 + 2 | 4 | 00   | 1   |
| 10 | 11 | 2 + 3 | 5 | 01   | 1   |
| 11 | 00 | 3 + 0 | 3 | 11   | 0   |
| 11 | 01 | 3 + 1 | 4 | 00   | 1   |
| 11 | 10 | 3 + 2 | 5 | 01   | 1   |
| 11 | 11 | 3 + 3 | 6 | 10   | 1   |

The circuit diagram is as follows
```
A0 -----|
B0 ----- XOR --- C0
         |
         |
	 AND
	 |
	 with K
	 |
	 |
A1  ---XOR-----|
B1  ---|       XOR --- C1
               |
	       |
	       K1
```
The Process of the additions
* Let A = 11 and B = 11
* Add the rightmost bits
   * A0 = 1 and B0 = 1
   * 1 + 1 = 10, K0 = 10 and C0 = 1
* Add the rightmost bits
   * A1 = 1 and B1 = 1
   * 1 + 1 + 1 (K0 = 10) = 110 or K = 1 and c1 = 1

Final answer, C = 10 and K = 1 or 100


To analyze the circut, analyze the minimum and maximum values.
* 00 + 00
* 11 + 11

Analyze additions
* 00 + 00 = 000
* 11 + 11 = 110

Therefore
* 00 + 00 = 00 where C1 =0 and C0 = 0
* 11 + 11 = 110 where C1 =1 and C1 = 0 and K = 1
