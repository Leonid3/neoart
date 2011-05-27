
      FUNCTION C2(ALPHA,GINV)
C     FUNCTION DEFINED BY HIRSHMAN AND SIGMAR EQ. 6.73

      IMPLICIT NONE

      REAL C2, ALPHA, GINV

      C2 = 1.5 - (0.29+1.20*ALPHA)/(0.59+ALPHA+1.34*GINV**2)

      RETURN 
      END