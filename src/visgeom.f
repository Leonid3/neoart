
      SUBROUTINE VISGEOM(RHO,THET,BGRADP,RBT,B,DPSIDR)
C--------------------------------------------------------------------
C      SUBROUTINE THAT MUST BE SUPLIED BY THE USER.
C
C      INPUT:  RHO     : THE FLUX SURFACE LABEL.
C              THET    : ANGLE IN HAMADA COORDINATES B GRAD THET = A 
C                        FLUX FUNCTION. THET IS ASSUMED TO LIE IN THE 
C                        RANGE [0,1] (AND CYCLIC)
C      OUTPUT: BGRADP  : THE FLUX FUNCTION B GRAD THET
C              RBT     : THE FLUX FUNCTION R TIMES B_T
C              B         THE MAGNETIC FIELD IN (RHO,THET) THE THIRD 
C                        COORDINATE IS ASSUMED TO BE INGNORABLE
C              DPSIDR  : D PSI / D RHO: A FLUX FUNCTION
C
C
C      BELOW THE QUANTITIES ARE CACULATED FOR CIRCULAR SURFACES WITH
C        BT : THE TOROIDAL MAGNETIC FIELD ON THE MAGNETIC AXIS
C        RN : THE MAJOR RADIUS OF THE MAGNETIC AXIS
C        Q  : THE SAFETY FACTOR OF THE SURFACE
C        EPS: THE INVERSE ASPACT RATIO ( = RHO )
C
C--------------------------------------------------------------------

      IMPLICIT NONE

      REAL*8 RHO, THET, BT, RN, Q, EPS, CHI, CHIO, TWOPI, BGRADP, B,
     +       B0, RBT, E, DPSIDR
      INTEGER ITEL

      CALL CIRCGEOM(2,RHO,RN,E,Q,B0)
      EPS = E

      BT = B0 * SQRT(1. - E**2/(Q**2*(1.-E**2) + E**2))
      
      RBT = RN*BT
      
C     THE CONSTANT 2 PI
      TWOPI = 8.*ATAN(1.)

C     THE VALUE OF THE FLUX FUNCTION B GRAD P
      BGRADP = BT / ( TWOPI * Q * RN * SQRT(1-EPS**2) )  

C     THE VALUE OF DPSIDR
      DPSIDR = RBT *E / (Q * SQRT(1-E**2))

C     CALCULATE THE POLOIDAL ANGLE
      CHIO = 2.*TWOPI
      CHI = TWOPI*THET
      ITEL = 0
 100  CONTINUE
        ITEL = ITEL + 1
        IF (ITEL.GT.1000) STOP 'ERR 1: NO CONVERGENCE IN VISGEOM'
        CHIO = CHI
        CHI = TWOPI*THET - EPS*SIN(CHI)
        IF (ABS(CHI-CHIO).GT.1E-6) GOTO 100

C     THE VALUE OF THE MAGNETIC FIELD
      B = B0 / (1 + EPS*COS(CHI))

      RETURN
      END
