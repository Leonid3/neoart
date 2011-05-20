      PROGRAM TEST18
C-----------------------------------------------------------------
C     TEST THE DANDV ROUTINE. A PURE PLASMA IN THE BANANA 
C     PLATEAU REGIME 
C-----------------------------------------------------------------
      IMPLICIT NONE

      INTEGER NS,NC,NAR,ISEL,NZM,I,J,NMAXGR,IC,ID,ISHOT,
     +        NREG, NLEG, NENERGY, NCOF
      REAL*8 M,T,DEN,DS,XI,TAU, EPS, NORM, DD, VV, ZSP
      REAL*8 RHO, RN, E, Q, BN, VT, SIGMA, COEFF, EPARR
      LOGICAL NEOFRC, NEOGEO

c      PARAMETER(NAR = 5)
c      PARAMETER(NZM = 30)

      include 'elem_config.inc'
      
      parameter(NAR = NELMAX+2)
      parameter(NZM = NIONMAX)
      PARAMETER(NMAXGR = 1000)

      DIMENSION NC(NAR),ZSP(NAR,NZM),M(NAR),T(NAR),DEN(NAR,NZM),
     +          DS(NAR,NZM,2),XI(NAR,NZM),TAU(NAR,NAR),DD(NAR,NZM),
     +          VV(NAR,NZM),VT(NAR,NZM),COEFF(NAR,NZM,4),SIGMA(4)


C     FORCE THE BANANA PLATEAU REGIME
      NREG = 1
C     USE 3 LEGENDRE POLYNOMALS
      NLEG = 3
C     USE ENERGY SCATTERING IN THE COLLISION OPERATOR
      NENERGY = 1
C     USE ION - ELECTRON COLLISIONS
      NCOF = 1
C     USE ALL COUPLINGS IN THE PFIRSCH SCHLUETER REGIME
      SIGMA(1) = 1
      SIGMA(2) = 1
      SIGMA(3) = 1
      SIGMA(4) = 1
C     ON THE FIRST CALL RECACLULATE THE FRICTION/VISCOSITY AND
C     GEOMETRY PARAMETERS
      NEOFRC = .FALSE.
      NEOGEO = .TRUE. 

C     SET THE PARAMETERS FOR THE CIRCULAR GEOMETRY
      RHO = 0.1
      E = 1E-4
      Q = 2
      RN = 1.65
      BN = 2.5
C     COPY THEM INTO THE VALUES USED BY THE CODE
      CALL CIRCGEOM(1,RHO,RN,E,Q,BN)
C     USE THE CIRCULAR GEOMETRY APPROXIMATION
      ISEL = 2
C     SET THE ACCURACY
      EPS = 1E-5

C     THE NUMBER OF SPECIES IS 2
      NS = 2
C     IONS AND ELECTRONS HAVE ONLY ONE CHARGE 
      NC(1) = 1
      NC(2) = 1
C     THE MASS OF THE ELECTRON AND PROTON
      M(1) = 9.1096E-31
      M(2) = 1.6727E-27
C     THE CHARGE OF THE ELECTRON AND ION
      ZSP(1,1) = -1
      ZSP(2,1) = 2
C     THE DENSITY OF THE SPECIES IN 10^19 M^-3
      DEN(1,1) = 5.
      DEN(2,1) = 2.5 
C     THE TEMPERATURE IN KEV
      T(1) = 10.
      T(2) = 10.

C     THE THERMODYNAMIC FORCES
      DO 201 I = 1, NS
        DO 201 J = 1, NC(I)
          DS(I,J,1) = 0.
          DS(I,J,2) = 0.
 201  CONTINUE

C     CALCULATE THE BP CONTRIBUTION ONLY
      IC = 1
C     NO VT CONTRIBUTION
      ID = 0

C     SET EPARALLEL TO 1. EPARR = RN 
      EPARR = RN

      CALL NEOART(NS,NC,NAR,NZM,ZSP,M,T,DEN,DS,RHO,EPS,
     +            ISEL,ISHOT,NREG,SIGMA,NLEG,NENERGY,NCOF,
     +            NEOGEO,NEOFRC,IC,EPARR,COEFF)


      NORM = SQRT(E)/Q * BN
      DO 222 I = 1, NS 
        DO 222 J = 1, NC(I)
          VV(I,J) = COEFF(I,J,1)/(DEN(I,J)*1E19)
 222  CONTINUE

      DO 300 I = 1, NS
        DO 300 J = 1, NC(I)
          WRITE(*,*)'D NORM ',DD(I,J)*NORM,' VV NORM ',VV(I,J)*NORM
 300  CONTINUE

      RETURN 
      END



