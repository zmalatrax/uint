from testing import assert_equal, assert_true, assert_false

from uint import UInt, mask


fn test_mask() raises:
    assert_equal(mask(0), 0)
    assert_equal(mask(1), 1)
    assert_equal(mask(5), 0x1F)
    assert_equal(mask(63), UInt64.MAX >> 1)
    assert_equal(mask(64), UInt64.MAX)


fn test_max() raises:
    var x1 = UInt[1, 1].max()
    var y1 = UInt[1, 1](1)
    assert_true(x1 == y1)

    var x2 = UInt[7, 1].max()
    var y2 = UInt[7, 1](127)
    assert_true(x2 == y2)

    var x3 = UInt[256, 4].max()
    var y3 = UInt[256, 4](UInt64.MAX, UInt64.MAX, UInt64.MAX, UInt64.MAX)
    assert_true(x3 == y3)


fn test_min() raises:
    var zero = UInt[128, 2].zero()
    assert_true(zero == UInt[128, 2].min())
    assert_true(zero == UInt[128, 2](0))


fn test_eq() raises:
    var x = UInt[256, 4].zero()
    var y = UInt[256, 4](1)
    assert_false(x == y)
    assert_true(x != y)


fn test_gt() raises:
    var max1 = UInt[1, 1](1)
    assert_true(max1 > UInt[1, 1](0))
    assert_false(max1 > max1)

    var max2 = UInt[256, 4].max()
    assert_true(
        max2 > UInt[256, 4](UInt64.MAX, UInt64.MAX - 1, UInt64.MAX, UInt64.MAX)
    )


fn test_ge() raises:
    var max1 = UInt[1, 1](1)
    assert_true(max1 >= UInt[1, 1](0))
    assert_true(max1 >= max1)

    var max2 = UInt[256, 4].max()
    assert_true(
        max2 >= UInt[256, 4](UInt64.MAX, UInt64.MAX - 1, UInt64.MAX, UInt64.MAX)
    )
    assert_true(max2 >= max2)


fn test_lt() raises:
    var min1 = UInt[1, 1](0)
    assert_true(min1 < UInt[1, 1](1))
    assert_false(min1 < min1)

    var min2 = UInt[256, 4].min()
    assert_true(
        min2 < UInt[256, 4](UInt64.MAX, UInt64.MAX - 1, UInt64.MAX, UInt64.MAX)
    )


fn test_le() raises:
    var min1 = UInt[1, 1](0)
    assert_true(min1 <= UInt[1, 1](1))
    assert_true(min1 <= min1)

    var min2 = UInt[256, 4].min()
    assert_true(
        min2 <= UInt[256, 4](UInt64.MAX, UInt64.MAX - 1, UInt64.MAX, UInt64.MAX)
    )
    assert_true(min2 <= min2)


fn test_add() raises:
    var x = UInt[256, 4].max()
    var y = UInt[256, 4](1)
    var res = x + y
    assert_true(res == UInt[256, 4].zero())

    var z = UInt[256, 4](UInt64.MAX, 0, 1)
    var res_2 = y + z
    assert_true(res_2 == UInt[256, 4](0, 1, 1))


fn test_sub() raises:
    var x = UInt[256, 4](1)
    var y = UInt[256, 4].zero()
    var res_1 = x - x
    var res_2 = x - y
    var res_3 = y - x
    assert_true(res_1 == UInt[256, 4].zero())
    assert_true(res_2 == x)
    assert_true(res_3 == UInt[256, 4].max())

    var z = UInt[256, 4](1, 0, UInt64.MAX)
    var res_4 = z - x - x
    assert_true(res_4 == UInt[256, 4](UInt64.MAX, UInt64.MAX, UInt64.MAX - 1))
