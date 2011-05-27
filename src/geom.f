
      SUBROUTINE GEOM(NMG,ISEL,ISHOT,RHO,EPS,BAV,B2AV,BI2A,RBT,BGRADP,
     +                DPSIDR,RNQ,FC,GCLASS,FM,MMX,R2I)
C--------------------------------------------------------------------
C     THIS SUBROUTINE CALCULATES ALL THE QUANTITIES RELATED WITH THE
C     GEOMETRY. SEVERAL POSSIBILITIES TO SUPPLY INPUT TO THIS ROUTINE
C     EXIST. ONE CAN EITHER USE ANALYTIC EXPRESSIONS FOR A CIRCULAR
C     EQUILIBRIUM, READ THE COEFFICIENTS FROM FILE (INTERFACE TO 
C     ASDEX UPGRADE, OR CALL A ROUTINE THAT SUPLIES THE MAGNETIC FIELD
C     INFORMATION IN HAMADA COORDINATES. THESE OPTIONS ARE SELECTED 
C     THROUGH THE PARAMETER ISEL.
C
C     INPUT   NMG    :  MAXIMUM NUMBER OF QUANTITIES IN FM USED FOR
C                       CONSISTENCY CHECK.
C             ISEL   :  PARAMETER THAT SELECTS THE VARIOUS OPTIONS
C                       1 USE HAMADA COORDINATES AND CALL VISGEOM
C                       2 USE CIRCULAR GEOMETRY
C                       3 READ THE PARAMETERS FROM FILE
C             ISHOT  :  SHOT NUMBER, ONLY USED IF ISEL = 3
C             RHO    :  THE SURFACE LABEL
C             EPS    :  ACCURACY REQUIRED.
C     OUTPUT  BAV    :  AVERAGE OF THE MAGNETIC FIELD STRENGTH
C             B2AV   :  AVERAGE OF THE MAGNETIC FIELD STRENGTH SQUARED.
C             BI2A   :  AVERAGE OF THE INVERSE MAGNETIC FIELD STRENGTH
C                       SQUARED. 
C             RBT    :  THE PRODUCT OF MAJOR RADIUS AND TOROIDAL MAGN.
C                       FIELD
C             BGRADP :  INNER PRODUCT OF DIRECTION OF MAGNETIC FIELD
C                       AND GRADIENT OF THETA, A FLUX FUNCTION 
C             DPSIDR :  GRADIENT OF POLOIDAL FLUX TOWARDS DIMENSIONAL 
C                       RADIAL COORDINATE
C             RNQ    :  FIELD LINE LENGTH (APPROX R * Q)
C             FC     :  NUMBER OF PASSING PARTICLES
C             GCLASS :  GEOMETRY DEPENDENT COEFFICIENT FOR THE CAL-
C                       CULATION OF CLASSICAL TRANSPORT. GCLASS = 
C                       < R^2 B_P^2 / B^2 >
C             FM     :  ARRAY(NMAXGR) COEFFICIENTS NEEDED TO 
C                       CALCULATE THE VISCOSITY IN THE PFIRSCH 
C                       SCHLUETER REGIME.
C             MMX    :  THE ACTUAL NUMBER OF FOURIER COEFFICIENTS
C             R2I    :  FLUX SURFACE AVERAGE OF R^-2
C
C     THE ROUTINE CALL THE FOLOWING SUBROUTINES
C
C     VISGEOM :  IF ISEL =1 THE GEOMETRY SHOULD BE SUPLIED IN HAMADA 
C                COORDINATES
C     CIRCGEOM:  IF ISEL =2 THE PARAMETERS OF CIRCULAR GEOMETRY ARE 
C                SUPLIED THROUGH THIS ROUTINE
C--------------------------------------------------------------------

      IMPLICIT NONE

      REAL RHO, EPS
      INTEGER NMAXGR, ISEL, NMG

      PARAMETER(NMAXGR = 1000)

      REAL BMAX, TMAX, DTHET, THET, BGRADP, TWOPI, BDUM, BAV,
     +       B2AV, ERR, ERROR, LAM, DLAM, FDENOM, FC, FCO, PI,
     +       RN, E, BN, Q, DUM, BI2A, RBT, DPSIDR, RNQ, GCLASS,
     +       R2I
      REAL B(NMAXGR), THETA(NMAXGR),SIN1(NMAXGR),SIN2(NMAXGR),
     +       COS1(NMAXGR), COS2(NMAXGR), FM(NMAXGR), A(5)
      INTEGER NGR,MMX,I,J,NC,NEW_READ,ISHOT
      REAL RAXIS, RGEO, IDLP, COSB2, SINB2, COSBL, 
     +       SINBL
      DIMENSION COSB2(3), SINB2(3), COSBL(3), SINBL(3)
 
      DATA NEW_READ / 1 / 

C     THE CONSTANT PI, 2 PI
      PI = 4.*ATAN(1.)
      TWOPI = 2.*PI

      IF (NMG.NE.NMAXGR) CALL PERR(3)
      GOTO(1,10000,20000) ISEL
      RETURN

C     IN THIS PART THE COEFFICIENTS ARE CALCULATED THROUGH CALLS
C     TO THE ROUTINE VISGEOM WHICH SHOULD GIVE THE MAGNETIC FIELD
C     STRENGTH IN HAMADA COORDINATES.
C
C ***** WARNING: R2I IS NOT CALCULATED IN THIS PART THEREFORE 
C                NO WARE PINCH CAN BE CACULATED BUT THE REST 
C                IS O.K.
C
 1    CONTINUE

C     FIRST CALCULATE THE COEFFICIENTS F_M, THE NUMBER OF PASSING
C     PARTICLES F_C, AND THE QUANTITY (N GRAD THETA) IN THE COORDINATES
C     OF SHAING.
      
C     THE INITIAL CHOISE OF THE NUMBER OF GRID POINTS IN THE THETA 
C     DIRECTION AND THE NUMBER OF TERMS IN THE FOURIER EXPANSION IN 
C     THE POLOIDAL ANGLE
      NGR = 200
      MMX = 20

 100  CONTINUE
C       SET THE ERROR ESTIMATE TO ZERO
        ERROR = 0. 

C       DISTANCE BETWEEN THE GRID IN THETA DIRECTION
        DTHET = 1 / REAL(NGR)

C       CALCULATE THE MAGNETIC FIELD ON THE GRID POINTS AND DETERMINE
C       THE MAXIMUM OF THE FIELD. (THE MINIMUM IS ASSUMED TO BE AT 
C       THET = 0)
        BMAX = 0.
        TMAX = 0.
        BAV  = 0.
        B2AV = 0.
        BI2A = 0.
        DO 200 I = 1, NGR
          THET = (I-1.)*DTHET
          CALL VISGEOM(RHO,THET,BGRADP,RBT,B(I),DPSIDR)
          BAV  = BAV  + B(I)
          B2AV = B2AV + B(I)**2
          BI2A = BI2A + 1/B(I)**2
          IF (B(I).GT.BMAX) THEN
            BMAX = B(I)
            TMAX = THET
          ENDIF
 200    CONTINUE
        BAV  = BAV  * DTHET
        B2AV = B2AV * DTHET
        BI2A = BI2A * DTHET
C       ESTIMATE THE ERROR IN THE INTEGRALS
        ERR = 0.
        DO 250 I = 2, NGR-1
          ERR = MAX(ERR, ABS( (B(I-1) - 2.*B(I) + B(I+1))/(DTHET**2) ))
 250    CONTINUE
        ERROR = MAX(DTHET**2*ERR/(ABS(BAV)), ERROR)
        IF (ERROR.GT.EPS) THEN
          NGR = NGR * 2
          IF (NGR.GT.NMAXGR) CALL PERR(5)
          GOTO 100
        ENDIF

C     CALCULATE THE POLOIDAL ANGLE IN THE COORDINATES OF SHAING
C     (THIS COORDINATE IS DENOTED THETA INSTEAD OF THET FOR THE 
C     HAMADA COORDINATES
      THETA(1) = 0.
      DO 300 I = 2, NGR
        THET = (I-1.5)*DTHET
        CALL VISGEOM(RHO,THET,BGRADP,RBT,BDUM,DPSIDR)
        THETA(I) = THETA(I-1) + BDUM*DTHET
 300  CONTINUE
      DO 400 I = 1, NGR
        THETA(I) = THETA(I) * TWOPI / BAV
 400  CONTINUE

C     CALCULATE THE COEFFICIENTS FM
C     FIRST DO THE INTEGRALS
      DO 1000 I = 1, MMX
        SIN1(I) = 0.
        SIN2(I) = 0.
        COS1(I) = 0.
        COS2(I) = 0.
        DO 1100 J = 1, NGR
          SIN1(I) = SIN1(I) + COS(I*THETA(J))*B(J)*LOG(B(J))
          SIN2(I) = SIN2(I) + COS(I*THETA(J))*B(J)**2
          COS1(I) = COS1(I) + SIN(I*THETA(J))*B(J)*LOG(B(J))
          COS2(I) = COS2(I) + SIN(I*THETA(J))*B(J)**2
 1100   CONTINUE
        FM(I) = 2. * ( I * TWOPI * BGRADP * DTHET )**2 / 
     +      (BAV**3 * B2AV) * (SIN1(I)*SIN2(I)+COS1(I)*COS2(I))
 1000 CONTINUE

      BGRADP = TWOPI * BGRADP / BAV
      
      RNQ = 1./BGRADP 

C     NOW DETERMINE THE NUMBER OF PASSING PARTICLES
      NC = 100
      FCO = 0.
 2000 CONTINUE
        IF (NC.GT.NMAXGR) STOP 'ERR 2 NO CONVERGENCE IN VISCOS'
        DLAM = 1./ (BMAX*REAL(NC))
        FC  = 0.
        DO 2100 I = 1, NC
          LAM = (I-0.5)*DLAM
          FDENOM = 0.
          DO 2200 J = 1, NGR
            FDENOM = FDENOM + SQRT(1.- LAM*B(J))*DTHET
 2200     CONTINUE
          FC = FC + LAM * DLAM / FDENOM
 2100   CONTINUE
        IF (FCO.EQ.0.) THEN
          FCO = FC
          NC = NC*2
          GOTO 2000
        ELSE
          IF (ABS(FCO-FC).GT.EPS*ABS(FC)) THEN
            FCO = FC
            NC = NC*2
            IF (NC.GT.1E6) CALL PERR(5)
            GOTO 2000
          ENDIF
        ENDIF

C     THE NUMBER OF TRAPPED AND PASSING PARTICLES IS  
      FC = 0.75*B2AV*FC 

C     THE QUANTITY GCLASS IS NOT YET PROGRAMMED FOR HAMADA 
C     COORDINATES
      GCLASS = 0.

      RETURN 

C     IN THIS PART ANALYTIC EXPRESSIONS FOR AN CIRCULAR GEOMETRY 
C     ARE USED. 
10000 CONTINUE

C     OBTAIN THE VALUES OF THE MAJOR RADIUS INVERSE ASPECT RATIO
C     SAFETY FACTOR AND MAGNETIC FIELD STRENGTH.
      CALL CIRCGEOM(2,RHO,RN,E,Q,BN)
 
C     FOR CIRCULAR SURFACE THE FLUX LABEL R IS USED. 
      DPSIDR = RN * BN / SQRT(1 + Q**2 * (1/E**2 - 1.))

C     AVERAGES OF THE MAGNETIC FIELD STRENGTHS
      BAV = BN
      B2AV = BN**2/SQRT(1-E**2)
      R2I  = 1./(RN**2*SQRT(1.-E**2))
      BI2A = (1 + 1.5 * E**2 ) / BN**2

C     THE PRODUCT OF MAJOR RADIUS AND TOROIDAL MAGNETIC FIELD
      RBT = SQRT(1 - E**2) * RN * BN / SQRT(1 + E**2 *(1/Q**2 - 1))

C     MEASURE OF THE FIELD LINE LENGTH
      RNQ = RN*Q

      BGRADP = 1/(RN*SQRT(E**2 + Q**2*(1-E**2)))

      A(1) = -1.46655
      A(2) = 1.0241
      A(3) = -1.20107
      A(4) = 1.356234
      A(5) = -0.662881

      DUM =  1 - E
      FC = DUM
      DO 10100 I = 1, 5
        DUM = DUM*SQRT(E)
        FC = FC + A(I)*DUM
10100 CONTINUE

      I = 1
10200 CONTINUE
      FM(I) = 2*I*BGRADP**2*((-1.+SQRT(1-E**2))/E)**(2*I)
      DUM = (2 - E**2 - 2*SQRT(1-E**2))/E**2
      DUM = I*DUM**(I-1) + (1-I)*DUM**I
      IF ((ABS(DUM).GT.0.01*EPS).OR.(I.LT.15)) THEN
        I = I+1
        IF (I.GT.NMAXGR) CALL PERR(5)
        GOTO 10200
      ENDIF
      MMX = I

C     THE GEOMETRY DEPENDENT QUANTITY FOR THE CALCULATION 
C     OF CLASSICAL TRANSPORT
      GCLASS = (RN*E)**2*(1 + 3.*E**2/2.)
     +          /(Q**2 + E**2 * (1 - Q**2))      
      RETURN

C     IN THIS PART THE COEFFICIENTS ARE READ FROM FILE
20000 CONTINUE
     
      call get_geom
     >     (ishot, new_read, rho,
     +      RAXIS, IDLP, BAV, B2AV, BI2A, RBT, FC,
     >      MMX, COSB2, SINB2, COSBL, SINBL,R2I)   

      IF (MMX.NE.3) STOP 'INCONSISTENT SETTINGS WITH NF.NE.3'

c***** WARNING RGEO IS SET TO A FIXED VALUE
      RGEO = 1.65
      
      DPSIDR = TWOPI*RHO*RGEO / IDLP

      BGRADP = TWOPI / (BAV*IDLP)

      DO 20100 I = 1, MMX
        FM(I) = 2.*(I*BGRADP)**2/(B2AV*BAV)*(COSB2(I)*COSBL(I)+
     +              SINB2(I)*SINBL(I))
20100 CONTINUE

      RNQ = 1. / BGRADP
  
      if (new_read.eq.1) new_read = 0
     
      RETURN
      END
