from .uint_errors import (
    EmptyString,
    HexStringTooBig,
    InvalidHexString,
    InvalidLimbsNumber,
    ValueTooLarge,
    MultiplicationOverflow,
)


@value
struct UInt[BITS: Int, LIMBS: Int](Stringable, Representable, Sized):
    """
    Struct implementing unsigned integers of arbitrary size.


    The most significant bit is at the right-most position.
    The array `[a_0, ..., a_n]` represents the integer
    2^{64 * n} * a_n + ... + 2 ^ 64 * a_1 + a_0
    """

    var limbs: InlineArray[UInt32, LIMBS]
    var bits: Int
    var mask: UInt32

    fn __init__(inout self, limbs: InlineArray[UInt32, LIMBS]) raises:
        """
        Initialize a `UInt[BITS, LIMBS]` given a fixed-array of limbs.
        """
        if LIMBS != nlimbs(BITS):
            raise InvalidLimbsNumber
        self.limbs = limbs
        self.bits = BITS
        self.mask = mask(BITS)

    fn __init__(inout self, *var_limbs: UInt32) raises:
        """
        Initialize a `UInt[BITS, LIMBS]` from a variadic number of `UInt32`.

        Raise if the provided arguments would construct a too large value.
        """
        var len = len(var_limbs)
        if len > LIMBS:
            raise ValueTooLarge
        var limbs = InlineArray[UInt32, LIMBS](0)
        var i = 0
        for limb in var_limbs:
            limbs[i] = limb
            i += 1
        self.__init__(limbs)

    fn __init__(inout self, hex_string: String, checked: Bool = True) raises:
        """
        Initialize a `UInt[BITS, LIMBS]` from a hexstring.
        It can contain '0x' or not.

        Flag `checked` whether to verify input string being an hex string.
        """
        var str = hex_string.removeprefix("0x")
        var str_len = len(str)

        if str_len == 0:
            raise EmptyString

        if checked:
            var is_hex = True
            for i in range(str_len):
                if str[i] not in String.HEX_DIGITS:
                    is_hex = False
                    break
            if not is_hex:
                raise InvalidHexString

        var max_hex_chars = LIMBS * 8
        if str_len > max_hex_chars:
            raise HexStringTooBig

        var limbs = InlineArray[UInt32, LIMBS](0)
        var q: Int
        var rem: Int
        q, rem = divmod(str_len, 4)
        for i in range(q):
            limbs[i] = int(str[i * 4 : (i + 1) * 4], 16)
        if rem:
            limbs[q] = int(str[q * 4 : q * 4 + rem], 16)

        self.__init__(limbs)

    fn __len__(self) -> Int:
        return self.limbs.__len__()

    @staticmethod
    @always_inline("nodebug")
    fn zero() raises -> Self:
        """
        Return the `UInt[BITS, LIMBS]` zero.
        """
        return Self(InlineArray[UInt32, LIMBS](0))

    @staticmethod
    @always_inline("nodebug")
    fn min() raises -> Self:
        """
        Return the smallest `UInt[BITS, LIMBS]`, which is zero.

        Synonym of the `zero()` method.
        """
        return Self.zero()

    @staticmethod
    @always_inline("nodebug")
    fn max() raises -> Self:
        """
        Return the highest `UInt[BITS, LIMBS]`, 2 ** BITS - 1.
        """
        var limbs = InlineArray[UInt32, LIMBS](UInt32.MAX)
        if BITS > 0:
            limbs[LIMBS - 1] &= mask(BITS)
        return Self(limbs)

    @always_inline("nodebug")
    fn __eq__(self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[i] != other.limbs[i]:
                return False
        return True

    @always_inline("nodebug")
    fn __ne__(self, other: Self) -> Bool:
        return not self.__eq__(other)

    @always_inline("nodebug")
    fn __gt__(self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[LIMBS - 1 - i].__gt__(other.limbs[LIMBS - 1 - i]):
                return True
        return False

    @always_inline("nodebug")
    fn __ge__(self, other: Self) -> Bool:
        return self.__eq__(other) or self.__gt__(other)

    @always_inline("nodebug")
    fn __lt__(self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[LIMBS - 1 - i].__lt__(other.limbs[LIMBS - 1 - i]):
                return True
        return False

    @always_inline("nodebug")
    fn __le__(self, other: Self) -> Bool:
        return self.__eq__(other) or self.__lt__(other)

    @always_inline("nodebug")
    fn abs_diff(self, other: Self) raises -> Self:
        if self < other:
            return other - self
        return self - other

    @always_inline("nodebug")
    fn __add__(self, rhs: Self) raises -> Self:
        """
        Calculates `self + rhs`.
        """
        return self.add_with_overflow(rhs)[0]

    @always_inline("nodebug")
    fn __radd__(self, rhs: Self) raises -> Self:
        """
        Calculates `rhs + self`.
        """
        return self.__add__(rhs)

    @always_inline("nodebug")
    def __iadd__(inout self, rhs: Self) -> None:
        """
        Calculates `self += rhs`.
        """
        self = self.__add__(rhs)

    @always_inline("nodebug")
    fn add_with_overflow(self, rhs: Self) raises -> (Self, Bool):
        """
        Calculates `self + rhs`.

        Returns a tuple of the addition along a boolean indicating whether
        an arithmetic overflow would occur. If an overflow would have occured
        then the wrapped value is returned.
        """

        @parameter
        fn u64_carrying_add(
            lhs: UInt32, rhs: UInt32, carry: Bool
        ) -> (UInt32, SIMD[DType.bool, 1]):
            var add_res_1 = lhs.add_with_overflow(rhs)
            var add_res_2 = add_res_1[0].add_with_overflow(carry)
            return (add_res_2[0], add_res_1[1] or add_res_2[1])

        if BITS == 0:
            return (Self.zero(), False)

        var carry: SIMD[DType.bool, 1] = False
        var limbs = InlineArray[UInt32, LIMBS](0)
        var i = 0
        while i < LIMBS:
            (limbs[i], carry) = u64_carrying_add(
                self.limbs[i], rhs.limbs[i], carry
            )
            i += 1
        var overflow = UInt32(carry) or self.limbs[LIMBS - 1] > self.mask
        limbs[LIMBS - 1] &= self.mask
        return (Self(limbs), Bool(overflow))

    @always_inline("nodebug")
    fn __neg__(self) raises -> Self:
        return Self.zero() - self

    @always_inline("nodebug")
    fn __sub__(self, rhs: Self) raises -> Self:
        """
        Calculates `self - rhs`.
        """
        return self.sub_with_overflow(rhs)[0]

    @always_inline("nodebug")
    fn __rsub__(self, rhs: Self) raises -> Self:
        """
        Calculates `rhs - self`.
        """
        return self.__sub__(rhs)

    @always_inline("nodebug")
    def __isub__(inout self, rhs: Self) -> None:
        """
        Calculates `self -= rhs`.
        """
        self = self.__sub__(rhs)

    @always_inline("nodebug")
    fn sub_with_overflow(self, rhs: Self) raises -> (Self, Bool):
        """
        Calculates `self - rhs`.

        Returns a tuple of the substraction along a boolean indicating whether
        an arithmetic underflow would occur. If an underflow would have occured
        then the wrapped value is returned.
        """

        @parameter
        fn u64_carrying_sub(
            lhs: UInt32, rhs: UInt32, carry: Bool
        ) -> (UInt32, SIMD[DType.bool, 1]):
            var sub_res_1 = lhs.sub_with_overflow(rhs)
            var sub_res_2 = sub_res_1[0].sub_with_overflow(carry)
            return (sub_res_2[0], sub_res_1[1] or sub_res_2[1])

        if BITS == 0:
            return (Self.zero(), False)

        var carry: SIMD[DType.bool, 1] = False
        var limbs = InlineArray[UInt32, LIMBS](0)
        var i = 0
        while i < LIMBS:
            (limbs[i], carry) = u64_carrying_sub(
                self.limbs[i], rhs.limbs[i], carry
            )
            i += 1
        var overflow = UInt32(carry) or self.limbs[LIMBS - 1] > self.mask
        limbs[LIMBS - 1] &= self.mask
        return (Self(limbs), Bool(overflow))

    fn __rmul__(self, rhs: Self) raises -> Self:
        """
        Calculates `rhs * self`.
        """
        return self.__mul__(rhs)

    fn __imul__(inout self, rhs: Self) raises -> None:
        """
        Calculates `self *= rhs`.
        """
        self = self.__mul__(rhs)

    fn __mul__(self, rhs: Self) raises -> Self:
        """
        Calculates `self * rhs`.
        """
        var n = 0
        var t = 0
        for i in range(LIMBS):
            if self.limbs[i] != UInt32.MIN:
                n = i + 1
            if rhs.limbs[i] != UInt32.MIN:
                t = i + 1
        if n + t >= LIMBS:
            raise MultiplicationOverflow
        var limbs = InlineArray[UInt32, LIMBS](0)
        var carry = UInt64(0)

        for i in range(t + 1):
            for j in range(n + 1):
                var uv: UInt64 = limbs[i + j].cast[DType.uint64]() + (
                    self.limbs[j].cast[DType.uint64]()
                    * rhs.limbs[i].cast[DType.uint64]()
                ) + carry
                limbs[i + j] = uv.cast[DType.uint32]()
                carry = uv >> 32
            limbs[i + n + 1] = carry.cast[DType.uint32]()
            carry = 0
        if carry != 0:
            raise Error("Carry is not zero")
        return Self(limbs)

    @always_inline("nodebug")
    fn __str__(self) -> String:
        var str: String = "["
        for i in range(LIMBS - 1):
            var hex = hex(self.limbs[i])
            str = str + hex + ", "
        return str + hex(self.limbs[-1]) + "]"

    @always_inline("nodebug")
    fn __repr__(self) -> String:
        var limbs_repr: String = "InlineArray[UInt32, " + String(LIMBS) + "]("
        for i in range(LIMBS - 1):
            limbs_repr += repr(self.limbs[i]) + ", "
        limbs_repr += repr(self.limbs[LIMBS - 1]) + ")"
        return (
            "UInt["
            + repr(BITS)
            + ", "
            + repr(LIMBS)
            + "](limbs=("
            + limbs_repr
            + "), bits=("
            + repr(self.bits)
            + "), mask=("
            + repr(self.mask)
            + ")"
        )


@always_inline("nodebug")
fn nlimbs(bits: Int) -> Int:
    """
    Return the number of UInt32 limbs required to represent the given number of bits.
    """
    return (bits + 31) // 32


@always_inline("nodebug")
fn mask(bits: Int) -> UInt32:
    """
    Return the mask to apply to the highest limb to get the correct number of bits.
    """
    if bits == 0:
        return 0
    var limb_bits = bits % 32
    if limb_bits == 0:
        return UInt32.MAX
    return (1 << limb_bits) - 1
