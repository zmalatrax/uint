# Mojo `uint` package - Multiple-precision integer arithmetic

> Experimental package - Do not use in production.
>
> Work In Progress

Implements `UInt[BITS, LIMBS]`, the ring of numbers modulo $2^{BITS}$.
It requires two parameters: the number of bits and
the number of 32-bit 'limbs' required to store those bits.

This package is inspired by the Rust crate [`uint`](https://github.com/recmo/uint/tree/main).
Some algorithms taken from [Handbook of applied cryptography](https://cacr.uwaterloo.ca/hac/about/chap14.pdf)

```mojo
from uint.uint import UInt
var integer = UInt[33, 2](1, 2)
```

`LIMBS` is equal to $\left \lceil \frac{BITS}{32} \right \rceil$.

For commonly used size, an `alias` has been defined:

`U1` , `U8` , `U16` , `U32` ,
`U64` , `U128` , `U160` , `U192` ,
`U256` , `U320` , `U384` , `U448` ,
`U512` , `U768` , `U1024` , `U2048` ,
`U4096`

## Features

| Feature                       | Done?   |
| ----------------------------- | ------- |
| Create from limbs fixed-array | &#9745; |
| Create from variadic UInt32   | &#9745; |
| Create from hex string        | &#9745; |
| Comparison operators          | &#9745; |
| Addition                      | &#9745; |
| Substraction                  | &#9745; |
| Negate                        | &#9745; |
| Absolute difference           | &#9745; |
| Multiplication                | &#9745; |
| Division                      | &#9744; |
| Squaring                      | &#9744; |
| Exponentiation                | &#9744; |
| gdc                           | &#9744; |
| log                           | &#9744; |
| root                          | &#9744; |
| Modular arithmetic            | &#9744; |
| Bits conversion               | &#9744; |
| Bytes array conversion        | &#9744; |
| Bit shifts                    | &#9744; |
| Bit logic                     | &#9744; |
| `print`                       | &#9745; |
| `repr`                        | &#9745; |

## To do

- `square`
- `div`
- `pow`
- `gcd`
- `log`
- `root`
- Modular arithmetic on a given modulo, to implement prime fields
- Constructor from any radix (base 2 to base 64)
- Bits conversion
- Bytes array conversion
- Conversion with standard types UInt8, UInt16, UInt32, UInt64 (?)
- bit operations
  - `shl`
  - `shr`
  - `and`
  - `or`
  - `xor`
