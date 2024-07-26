from testing import assert_equal, assert_true, assert_false

from uint import UInt, mask


fn test_mask() raises:
    assert_equal(mask(0), 0)
    assert_equal(mask(1), 1)
    assert_equal(mask(5), 0x1F)
    assert_equal(mask(63), UInt64.MAX >> 1)
    assert_equal(mask(64), UInt64.MAX)


fn test_eq() raises:
    var x = UInt[256, 4].zero()
    var y = UInt[256, 4](1)
    assert_false(x == y)
    assert_true(x != y)
