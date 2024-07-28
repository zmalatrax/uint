alias InvalidLimbsNumber: Error = Error(
    "Cannot construct a UInt[BITS, LIMBS] from incorrect LIMBS."
)

alias ValueTooLarge: Error = Error("Value is too large for UInt[BITS, LIMBS].")

alias MultiplicationOverflow: Error = Error("Multiplication overflow.")

alias EmptyString: Error = Error("The input string is empty.")

alias InvalidHexString: Error = Error(
    "The string contains non-hexadecimal characters."
)

alias HexStringTooBig: Error = Error(
    "The input string value is bigger than the maximum value of this type."
)
