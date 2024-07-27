from testing import assert_true, assert_false

from uint.uint import UInt, mask, nlimbs

alias NON_ZERO_BITS: List[Int] = List(
    1, 2, 63, 64, 65, 127, 128, 129, 256, 384, 512, 4096
)

alias SIZES: List[Int] = List(
    0, 1, 2, 63, 64, 65, 127, 128, 129, 256, 384, 512, 4096
)


fn const_for[list: List[Int], f: fn[Int] () raises -> None]() raises:
    @parameter
    for i in range(len(list)):
        f[list[i]]()


fn test_mask() raises:
    assert_true(mask(0) == 0)
    assert_true(mask(1) == 1)
    assert_true(mask(5) == 0x1F)
    assert_true(mask(31) == UInt32.MAX >> 1)
    assert_true(mask(32) == UInt32.MAX)


fn test_max() raises:
    var x1 = UInt[1, 1].max()
    var y1 = UInt[1, 1](1)
    assert_true(x1 == y1)

    var x2 = UInt[7, 1].max()
    var y2 = UInt[7, 1](127)
    assert_true(x2 == y2)

    var x3 = UInt[128, 4].max()
    var y3 = UInt[128, 4](UInt32.MAX, UInt32.MAX, UInt32.MAX, UInt32.MAX)
    assert_true(x3 == y3)


fn test_min() raises:
    var zero = UInt[128, 4].zero()
    assert_true(zero == UInt[128, 4].min())
    assert_true(zero == UInt[128, 4](0))


fn test_eq() raises:
    var x = UInt[128, 4].zero()
    var y = UInt[128, 4](1)
    assert_false(x == y)
    assert_true(x != y)


fn test_gt() raises:
    var max1 = UInt[1, 1](1)
    assert_true(max1 > UInt[1, 1](0))
    assert_false(max1 > max1)

    var max2 = UInt[128, 4].max()
    assert_true(
        max2 > UInt[128, 4](UInt32.MAX, UInt32.MAX - 1, UInt32.MAX, UInt32.MAX)
    )


fn test_ge() raises:
    var max1 = UInt[1, 1](1)
    assert_true(max1 >= UInt[1, 1](0))
    assert_true(max1 >= max1)

    var max2 = UInt[128, 4].max()
    assert_true(
        max2 >= UInt[128, 4](UInt32.MAX, UInt32.MAX - 1, UInt32.MAX, UInt32.MAX)
    )
    assert_true(max2 >= max2)


fn test_lt() raises:
    var min1 = UInt[1, 1](0)
    assert_true(min1 < UInt[1, 1](1))
    assert_false(min1 < min1)

    var min2 = UInt[128, 4].min()
    assert_true(
        min2 < UInt[128, 4](UInt32.MAX, UInt32.MAX - 1, UInt32.MAX, UInt32.MAX)
    )


fn test_le() raises:
    var min1 = UInt[1, 1](0)
    assert_true(min1 <= UInt[1, 1](1))
    assert_true(min1 <= min1)

    var min2 = UInt[128, 4].min()
    assert_true(
        min2 <= UInt[128, 4](UInt32.MAX, UInt32.MAX - 1, UInt32.MAX, UInt32.MAX)
    )
    assert_true(min2 <= min2)


fn test_add() raises:
    var x = UInt[128, 4].max()
    var y = UInt[128, 4](1)
    var res = x + y
    assert_true(res == UInt[128, 4].zero())

    var z = UInt[128, 4](UInt32.MAX, 0, 1)
    var res_2 = y + z
    assert_true(res_2 == UInt[128, 4](0, 1, 1))

    x += y
    assert_true(x == UInt[128, 4].zero())


fn test_sub() raises:
    var x = UInt[128, 4](1)
    var y = UInt[128, 4].zero()
    var res_1 = x - x
    var res_2 = x - y
    var res_3 = y - x
    assert_true(res_1 == UInt[128, 4].zero())
    assert_true(res_2 == x)
    assert_true(res_3 == UInt[128, 4].max())

    var z = UInt[128, 4](1, 0, UInt32.MAX)
    var res_4 = z - x - x
    assert_true(res_4 == UInt[128, 4](UInt32.MAX, UInt32.MAX, UInt32.MAX - 1))


fn test_abs_diff() raises:
    var x = UInt[128, 4](1)
    var y = UInt[128, 4].zero()
    assert_true(x.abs_diff(y) == x)
    assert_true(y.abs_diff(x) == UInt[128, 4](1))
    assert_true(x.abs_diff(x) == UInt[128, 4].zero())


fn test_mul() raises:
    var x = UInt[192, 6](5474, 456)
    var y = UInt[192, 6](845, 435)
    assert_true(x * y == UInt[192, 6](4625530, 2766510, 198360))

    var a = UInt[128, 4](9274)
    var b = UInt[128, 4](847)
    assert_true(a * b == UInt[128, 4](7855078))


fn test_neg_one() raises:
    fn neg_one[BITS: Int]() raises:
        alias LIMBS = nlimbs(BITS)
        alias U = UInt[BITS, LIMBS]
        assert_true(-U(1) != U(0))

    const_for[NON_ZERO_BITS, neg_one]()


fn test_commutative() raises:
    fn commutative[BITS: Int]() raises:
        alias LIMBS = nlimbs(BITS)
        alias U = UInt[BITS, LIMBS]
        var a = U.max()
        var b = U.max() - U(1)
        assert_true(a + b == b + a)
        assert_true(a - b == -(b - a))

    const_for[NON_ZERO_BITS, commutative]()


fn test_associative() raises:
    fn associative[BITS: Int]() raises:
        alias LIMBS = nlimbs(BITS)
        alias U = UInt[BITS, LIMBS]
        var a = U.max()
        var zero = U.zero()
        assert_true(a + zero == a)
        assert_true(a - zero == a)

    const_for[NON_ZERO_BITS, associative]()


fn test_inverse() raises:
    fn inverse[BITS: Int]() raises:
        alias LIMBS = nlimbs(BITS)
        alias U = UInt[BITS, LIMBS]
        var a = U.max()
        var zero = U.zero()
        assert_true(a + (-a) == zero)
        assert_true(a - a == zero)
        assert_true(-(-a) == a)

    const_for[NON_ZERO_BITS, inverse]()
