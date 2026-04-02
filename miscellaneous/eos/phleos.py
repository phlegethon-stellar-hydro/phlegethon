import numpy as np
import eos_fort 

id_P = 0
id_E = 1
id_dPdrho = 2
id_dPdT = 3
id_dEdrho = 4
id_dEdT = 5
id_cv = 6
id_chiT = 7
id_chirho = 8
id_gam1 = 9
id_sound = 10
id_cp = 11
id_gam2 = 12
id_gam3 = 13
id_nabla_ad = 14
id_s = 15
id_dsdrho = 16
id_dsdT = 17
id_delta = 18
id_eta = 19
id_nep = 20
id_phi = 21
id_dPdA = 22

id_tvars = 0
id_trho = 1
id_tT = 2
id_tdrho = 3
id_tdT = 4

def rhoT_given(eos_table,rho,T,abar=1.0,zbar=1.0,gamma_ideal=5.0/3.0,eos_mode=['ideal']):

    ideal = True
    ions = False
    radiation = False
    elepos = False
    coulomb = False
    pig = False

    if('ideal' in eos_mode):
        ideal = True
    else:
        ideal = False

    if('ions' in eos_mode):
        ions = True

    if('radiation' in eos_mode):
        radiation = True

    if('elepos' in eos_mode):
        elepos = True

    if('coulomb' in eos_mode):
        coulomb = True

    if('pig' in eos_mode):
        pig = True

    dim = np.ndim(rho)

    if(dim<3):
        rho = np.atleast_3d(rho)
        T = np.atleast_3d(T)
    
    if(np.ndim(abar)==0):
        abar = abar*np.ones_like(rho)
    else:
        abar = np.atleast_3d(abar)
        
    if(np.ndim(zbar)==0):
        zbar = zbar*np.ones_like(rho)
    else:
        zbar = np.atleast_3d(zbar)

    full = eos_fort.eos_fort_mod.rhot_given_3d(
	rho,T,abar,zbar,
	ideal,ions,radiation,
	elepos,coulomb,pig,
    gamma_ideal,
	eos_table[0],
	eos_table[1],eos_table[2],
	eos_table[3],eos_table[4])

    if(dim==0):
      full = full[:,0,0,0]
    if(dim==1):
      full = full[:,0,:,0]
    if(dim==2):
      full = full[:,:,:,0]
    return full

def rhoP_given(eos_table,rho,P,abar=1.0,zbar=1.0,Tguess=-1.0,gamma_ideal=5.0/3.0,eos_mode=['ideal']):

    ideal = True
    ions = False
    radiation = False
    elepos = False
    coulomb = False
    pig = False

    if('ideal' in eos_mode):
        ideal = True
    else:
        ideal = False

    if('ions' in eos_mode):
        ions = True

    if('radiation' in eos_mode):
        radiation = True

    if('elepos' in eos_mode):
        elepos = True

    if('coulomb' in eos_mode):
        coulomb = True

    if('pig' in eos_mode):
        pig = True

    dim = np.ndim(rho)

    if(dim<3):
        rho = np.atleast_3d(rho)
        P = np.atleast_3d(P)
    
    if(np.ndim(abar)==0):
        abar = abar*np.ones_like(rho)
    else:
        abar = np.atleast_3d(abar)
        
    if(np.ndim(zbar)==0):
        zbar = zbar*np.ones_like(rho)
    else:
        zbar = np.atleast_3d(zbar)

    try:
     if(Tguess<0):
      Tguess = -np.ones_like(rho)
     else:
      if((dim==0) or (dim==1) or (dim==2)):  
       Tguess = np.atleast_3d(Tguess)
    except:
     if((dim==0) or (dim==1) or (dim==2)):  
      Tguess = np.atleast_3d(Tguess)
     
    full,T = eos_fort.eos_fort_mod.rhop_given_3d(
	rho,P,Tguess,abar,zbar,
	ideal,ions,radiation,
	elepos,coulomb,pig,
    gamma_ideal,
	eos_table[0],
	eos_table[1],eos_table[2],
	eos_table[3],eos_table[4])

    if(dim==0):
      full = full[:,0,0,0]
      T = T[0,0,0]
    if(dim==1):
      full = full[:,0,:,0]
      T = T[0,:,0]
    if(dim==2):
      full = full[:,:,:,0]
      T = T[:,:,0]
    
    return full,T

def PT_given(eos_table,P,T,abar=1.0,zbar=1.0,rhoguess=-1.0,gamma_ideal=5.0/3.0,eos_mode=['ideal']):

    ideal = True
    ions = False
    radiation = False
    elepos = False
    coulomb = False
    pig = False

    if('ideal' in eos_mode):
        ideal = True
    else:
        ideal = False

    if('ions' in eos_mode):
        ions = True

    if('radiation' in eos_mode):
        radiation = True

    if('elepos' in eos_mode):
        elepos = True

    if('coulomb' in eos_mode):
        coulomb = True

    if('pig' in eos_mode):
        pig = True

    dim = np.ndim(P)

    if(dim<3):
        P = np.atleast_3d(P)
        T = np.atleast_3d(T)
    
    if(np.ndim(abar)==0):
        abar = abar*np.ones_like(P)
    else:
        abar = np.atleast_3d(abar)
        
    if(np.ndim(zbar)==0):
        zbar = zbar*np.ones_like(P)
    else:
        zbar = np.atleast_3d(zbar)

    try:
     if(rhoguess<0):
      rhoguess = -np.ones_like(T)
     else:
      if((dim==0) or (dim==1) or (dim==2)):  
       rhoguess = np.atleast_3d(rhoguess)
    except:
     if((dim==0) or (dim==1) or (dim==2)):  
      rhoguess = np.atleast_3d(rhoguess)
         
    full,rho = eos_fort.eos_fort_mod.pt_given_3d(
	P,T,rhoguess,abar,zbar,
	ideal,ions,radiation,
	elepos,coulomb,pig,
    gamma_ideal,
	eos_table[0],
	eos_table[1],eos_table[2],
	eos_table[3],eos_table[4])

    if(dim==0):
      full = full[:,0,0,0]
      rho = rho[0,0,0]
    if(dim==1):
      full = full[:,0,:,0]
      rho = rho[0,:,0]
    if(dim==2):
      full = full[:,:,:,0]
      rho = rho[:,:,0]
    
    return full,rho

def Ps_given(eos_table,P,s,rhoguess,Tguess,abar=1.0,zbar=1.0,gamma_ideal=5.0/3.0,eos_mode=['ideal']):

    ideal = True
    ions = False
    radiation = False
    elepos = False
    coulomb = False
    pig = False

    if('ideal' in eos_mode):
        ideal = True
    else:
        ideal = False

    if('ions' in eos_mode):
        ions = True

    if('radiation' in eos_mode):
        radiation = True

    if('elepos' in eos_mode):
        elepos = True

    if('coulomb' in eos_mode):
        coulomb = True

    if('pig' in eos_mode):
        pig = True

    dim = np.ndim(P)

    if(dim<3):
        P = np.atleast_3d(P)
        s = np.atleast_3d(s)
        rhoguess = np.atleast_3d(rhoguess)
        Tguess = np.atleast_3d(Tguess)
        
    if(np.ndim(abar)==0):
        abar = abar*np.ones_like(P)
    else:
        abar = np.atleast_3d(abar)
        
    if(np.ndim(zbar)==0):
        zbar = zbar*np.ones_like(P)
    else:
        zbar = np.atleast_3d(zbar)
         
    full,rho,T = eos_fort.eos_fort_mod.ps_given_3d(
	P,s,rhoguess,Tguess,abar,zbar,
	ideal,ions,radiation,
	elepos,coulomb,pig,
    gamma_ideal,
	eos_table[0],
	eos_table[1],eos_table[2],
	eos_table[3],eos_table[4])

    if(dim==0):
      full = full[:,0,0,0]
      rho = rho[0,0,0]
      T = T[0,0,0]
    if(dim==1):
      full = full[:,0,:,0]
      rho = rho[0,:,0]
      T = T[0,:,0]
    if(dim==2):
      full = full[:,:,:,0]
      rho = rho[:,:,0]
      T = T[:,:,0]
    
    return full,rho,T

