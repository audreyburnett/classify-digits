.globl abs
abs:
  ebreak
  blt zero, a0, done

  # Negate a0
  sub a0, x0, a0

done:
  ret
