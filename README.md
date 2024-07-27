# Mojo `uint` package using parameters

> Experimental package - Do not use in production.
>
> Work In Progress

Implements `UInt[BITS, LIMBS]`, the ring of numbers modulo $2^{BITS}$.
It requires two parameters: the number of bits and
the number of 64-bit 'limbs' required to store those bits.

This package is inspired by the Rust crate [`uint`](https://github.com/recmo/uint/tree/main).

```mojo
from uint.uint import UInt
var integer = UInt[65, 2](1, 2)
```

`LIMBS` is equal to $\left \lceil \frac{BITS}{64} \right \rceil$.

For commonly used size, an `alias` has been defined:

`U1` , `U8` , `U16` , `U32` ,
`U64` , `U128` , `U160` , `U192` ,
`U256` , `U320` , `U384` , `U448` ,
`U512` , `U768` , `U1024` , `U2048` ,
`U4096`

## To do

- `mul`
- `div`
- `pow`
- `gcd`
- `log`
- `root`
- Modular arithmetic, to implement prime fields
- Bits conversion
- Bytes array conversion
- Conversion with standard types UInt8, UInt16, UInt32, UInt64
