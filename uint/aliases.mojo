from .uint import UInt

alias U1 = UInt[1, 1]
"""`UInt` for 1 bit. Similar to `Bool`."""

alias U8 = UInt[8, 1]
"""`UInt` for 8 bits. Similar to `UInt8`."""

alias U16 = UInt[16, 1]
"""`UInt` for 16 bits. Similar to `UInt16`."""

alias U32 = UInt[32, 1]
"""`UInt` for 32 bits. Similar to `UInt32`."""

alias U64 = UInt[64, 2]
"""`UInt` for 64 bits. Similar to `UInt64`."""

alias U128 = UInt[128, 4]
"""`UInt` for 128 bits."""

alias U160 = UInt[160, 5]
"""`UInt` for 160 bits."""

alias U192 = UInt[192, 6]
"""`UInt` for 192 bits."""

alias U256 = UInt[256, 8]
"""`UInt` for 256 bits."""

alias U320 = UInt[320, 10]
"""`UInt` for 320 bits."""

alias U384 = UInt[384, 12]
"""`UInt` for 384 bits."""

alias U448 = UInt[448, 14]
"""`UInt` for 448 bits."""

alias U512 = UInt[512, 16]
"""`UInt` for 512 bits."""

alias U768 = UInt[768, 24]
"""`UInt` for 768 bits."""

alias U1024 = UInt[1024, 32]
"""`UInt` for 1024 bits."""

alias U2048 = UInt[2048, 64]
"""`UInt` for 2048 bits."""

alias U4096 = UInt[4096, 128]
"""`UInt` for 4096 bits."""
