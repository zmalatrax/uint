from uint_errors import InvalidLimbsNumber, ValueTooLarge


@value
struct UInt[BITS: Int, LIMBS: Int]():
    """
    Struct implementing unsigned integers of arbitrary size.
    """

    var limbs: InlineArray[UInt64, LIMBS]
    var bits: Int
    var mask: UInt64

    fn __init__(inout self, limbs: InlineArray[UInt64, LIMBS]) raises:
        """
        Initialize a `UInt[BITS, LIMBS]` given a fixed-array of limbs.
        """
        if LIMBS != nlimbs(BITS):
            raise InvalidLimbsNumber
        self.limbs = limbs
        self.bits = BITS
        self.mask = mask(BITS)

    fn __init__(inout self, *var_limbs: UInt64) raises:
        """
        Initialize a `UInt[BITS, LIMBS]` from a variadic number of `UInt64`.

        Raise if the provided arguments would construct a too large value.
        """
        var len = len(var_limbs)
        if len > LIMBS:
            raise ValueTooLarge
        var limbs = InlineArray[UInt64, LIMBS](0)
        var i = 0
        for limb in var_limbs:
            limbs[i] = limb
            i += 1
        self.__init__(limbs)

    @staticmethod
    @always_inline("nodebug")
    fn zero() raises -> Self:
        """
        Return the `UInt[BITS, LIMBS]` zero.
        """
        return UInt[BITS, LIMBS](InlineArray[UInt64, LIMBS](0))

    @staticmethod
    @always_inline("nodebug")
    fn min() raises -> Self:
        """
        Return the smallest `UInt[BITS, LIMBS]`, which is zero.

        Synonym of the `zero()` method.
        """
        return UInt[BITS, LIMBS].zero()

    @staticmethod
    @always_inline("nodebug")
    fn max() raises -> Self:
        """
        Return the highest `UInt[BITS, LIMBS]`, 2 ** BITS - 1.
        """
        var limbs = InlineArray[UInt64, LIMBS](UInt64.MAX)
        if BITS > 0:
            limbs[LIMBS - 1] &= mask(BITS)
        return UInt[BITS, LIMBS](limbs)

    @always_inline("nodebug")
    fn __eq__(inout self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[i] != other.limbs[i]:
                return False
        return True

    @always_inline("nodebug")
    fn __ne__(inout self, other: Self) -> Bool:
        return ~self.__eq__(other)

    @always_inline("nodebug")
    fn __gt__(inout self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[LIMBS - 1 - i].__gt__(other.limbs[LIMBS - 1 - i]):
                return True
        return False

    @always_inline("nodebug")
    fn __ge__(inout self, other: Self) -> Bool:
        return self.__eq__(other) or self.__gt__(other)

    @always_inline("nodebug")
    fn __lt__(inout self, other: Self) -> Bool:
        for i in range(LIMBS):
            if self.limbs[LIMBS - 1 - i].__lt__(other.limbs[LIMBS - 1 - i]):
                return True
        return False

    @always_inline("nodebug")
    fn __le__(inout self, other: Self) -> Bool:
        return self.__eq__(other) or self.__lt__(other)

    @always_inline("nodebug")
    fn __add__(inout self, rhs: Self) raises -> Self:
        """
        Calculates `self + rhs`.
        """
        return self.add_with_overflow(rhs)[0]

    @always_inline("nodebug")
    fn __radd__(inout self, rhs: Self) raises -> Self:
        """
        Calculates `rhs + self`.
        """
        return self.__add__(rhs)

    @always_inline("nodebug")
    fn add_with_overflow(inout self, rhs: Self) raises -> (Self, Bool):
        """
        Calculates `self + rhs`.

        Returns a tuple of the addition along a boolean indicating whether
        an arithmetic overflow would occur. If an overflow would have occured
        then the wrapped value is returned.
        """

        @parameter
        fn u64_carrying_add(
            lhs: UInt64, rhs: UInt64, carry: Bool
        ) -> (UInt64, SIMD[DType.bool, 1]):
            var add_res_1 = lhs.add_with_overflow(rhs)
            var add_res_2 = add_res_1[0].add_with_overflow(carry)
            return (add_res_2[0], add_res_1[1] | add_res_2[1])

        if BITS == 0:
            return (UInt[BITS, LIMBS].zero(), False)

        var carry: SIMD[DType.bool, 1] = False
        var i = 0
        while i < LIMBS:
            (self.limbs[i], carry) = u64_carrying_add(
                self.limbs[i], rhs.limbs[i], carry
            )
            i += 1
        var overflow = UInt64(carry) | self.limbs[LIMBS - 1] > self.mask
        self.limbs[LIMBS - 1] &= self.mask
        return (self, Bool(overflow))

    @always_inline("nodebug")
    fn __str__(inout self) -> String:
        var str: String = "["
        for i in range(LIMBS - 1):
            str = str + String(hex(self.limbs[i])) + ", "
        return str + String(hex(self.limbs[-1])) + "]"

    @always_inline("nodebug")
    fn __repr__(inout self) -> String:
        var str: String = "["
        for i in range(LIMBS - 1):
            str = str + self.limbs[i].__repr__() + ", "
        return str + self.limbs[-1].__repr__() + "]"


@always_inline("nodebug")
fn nlimbs(bits: Int) -> Int:
    """
    Return the number of UInt64 limbs required to represent the given number of bits.
    """
    return (bits + 63) // 64


@always_inline("nodebug")
fn mask(bits: Int) -> UInt64:
    """
    Return the mask to apply to the highest limb to get the correct number of bits.
    """
    if bits == 0:
        return 0
    var limb_bits = bits % 64
    if limb_bits == 0:
        return UInt64.MAX
    return (1 << limb_bits) - 1
