alias InvalidLimbsNumber: Error = Error(
    "Cannot construct a UInt[BITS, LIMBS] from incorrect LIMBS."
)

alias ValueTooLarge: Error = Error("Value is too large for UInt[BITS, LIMBS].")

alias MultiplicationOverflow: Error = Error("Multiplication overflow.")
