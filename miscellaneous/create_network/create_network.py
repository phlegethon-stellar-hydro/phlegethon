import numpy as np
import matplotlib.pyplot as plt
import re
import os
from scipy.interpolate import RegularGridInterpolator as interp2d

'''
This script generates Fortran code useful to Phlegethon's nuclear network solver and writes it to the provided Fortran setup file.

To do so, the following quantities must be defined:

  - sps: list of isotopes
  - T9: temperature in units of 10^9 K
  - rho: gas density in units of g cm^-3
  - tau: timescale of interest. The program will ignore all reactions whose timescale (computed at T9, rho, and assuming that 
    all mass fractional abundances are 1) is longer than tau
  - path_to_target: path to the repository containing the Fortran setup file
  - target=path_to_target+<filename.F90> : path to the actual Fortran setup file
  - end_target: desired end-program statement to have at the end of the Fortran setup file
  - path_to_data: path to the $(DATA) repository which contains nuclear reaction tables, partition functions, weak rates, etc.
  - full_output: if "True", in addition to the list of selected reactions, 
    the program prints some more information on the reactions themselves: their Q value in MeV, whether the reaction is a reverse one, and the timescale of the reaction in seconds
  - use_weak_rates=True/False: if "True", the program uses the reaction rates for weak reactions from the Langanke-Marinez-Pinedo table instead of the Jina Reaclib.
  - jina_reaclib_file: name of the jina reaclib file (to be stored in "path_to_data")

  Below is one example for the hot-CNO cycle
'''

sps = ['p','he4','c12','c13','n13','n14','n15','o14','o15'] 
T9 = 0.2
rho = 1e4
tau = 1.0e5

path_to_target = '../../tests/burning-bubble/'
target = path_to_target + 'app.F90'
end_target ='end program test'

path_to_data = '../../data/'

full_output = True
use_weak_rates = True

jina_reaclib_file = 'results03291232'

#----------------------------------------------------------#

Nav_mev_to_erg = 1.6021766e-6*6.02214076e23

#extract the mass and atomic number for a large list of isotopes
As = {}
Zs = {}

Ze = 1
Zno = 't'

with open("%s/sunet.dat"%(path_to_data)) as file_in:

    for line in file_in:
        
        linestr = str(line.strip())

        if(linestr=='n' or linestr=='p' or linestr=='d' or linestr=='t'):

            if(linestr=='n'):
                As[linestr] = 1
                Zs[linestr] = 0
            if(linestr=='p'):
                As[linestr] = 1
                Zs[linestr] = 1
            if(linestr=='d'):
                As[linestr] = 2
                Zs[linestr] = 1
            if(linestr=='t'):
                As[linestr] = 3
                Zs[linestr] = 1
          
        else:

         sub = re.findall(r'\d+', linestr)
         As[linestr] = float(sub[0])
         linestrc = linestr
         linestrc = linestrc.replace(sub[0],'')
         if(linestr=='al-6' or linestr=='al*6' or linestr=='al01' or linestr=='al02'):
          linestrc = 'al'

         if(linestrc!=Zno):
             Zno = linestrc
             Ze += 1
 
         Zs[linestr] = Ze

A = []
Z = []
for sp in sps:
 A.append(As[sp])
 Z.append(Zs[sp])

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

nsps = len(sps)
at_least_one_ec = False

number = {
2 : 'rp2',
3 : 'rp3'}

class Reaction: #Jina reaclib reaction
  def __init__(self):
      self.R = []
      self.P = []
      self.R_lbl = []
      self.P_lbl = []
      self.multR = []
      self.multP = []
      self.dN = []
      self.Q = 0.0
      self.reac_type = 100
      self.coeff = np.zeros((7))
      self.reverse = False
      self.ec = False
      self.is_triple_alpha = False
      self.is_pep = False
      self.is_weak = False
      self.tau_rec = 1.0e100
      self.is_refined = False

class Network: #Network class

  def __init__(self):

      self.reactions = []

  def check_for_duplicates(self,ref): #counts the number of occurrences of reference reaction in network
      
      mult = 0
      irs = []
      tau_eff = 0.0
      for ir,reac in enumerate(self.reactions):
       if(reac.R==ref.R and reac.P==ref.P and reac.Q==ref.Q):
         mult += 1
         irs.append(ir) #if reaction matches, append reaction to list
         tau_eff += 1.0/reac.tau_rec

      tau_eff = 1.0/tau_eff

      return mult,irs,tau_eff #return multiplicity, list of reaction indices, and effective reaction timescale

  def remove_duplicates(self,ref):

      mult,irs,tau_eff = self.check_for_duplicates(ref) #check reaction indices corresponding to reference reaction

      self.reactions = [i for j, i in enumerate(self.reactions) if j not in irs[1:]] #retain only reaction of kind ref at index irs[0]
 
      return mult,tau_eff

def jina_tau(a,tp,T9,rho,reac_lbl=''): #Jina reaction time scale

 r = a[0] + a[6]*np.log(T9)
 for i in range(1,6):
  r += a[i]*T9**((2.0*i-5.0)/3.0)
 r = np.exp(r)

 if(tp==1 or tp==2 or tp==3):
  if(reac_lbl[:2]=='ec'): #for electron captures we need to multiply rate by density
   r *= rho

 if(tp==4 or tp==5):
  r *= rho
  if(reac_lbl[:2]=='ec'): 
   r *= rho

 if(tp==8):
  r *= rho**2
  if(reac_lbl[:2]=='ec'): 
   r *= rho

 if(tp==6 or tp==7 or tp==9 or tp==10 or tp==11):
  r = 1e-50

 if(r<1e-50):
  r = 1e-50

 return 1.0/r

coeff = np.zeros((7)) #jina rate coefficients

net = Network()

#load langanke-martinez-pinedo weak rates
         
rhoye_array = np.zeros((11))
T_array = np.zeros((13))

R_exclude = []
P_exclude = []

if(use_weak_rates):
 print("Starting weak rates loading...")
 
 skip_reactions = []

 with open("%s/lmp_weak_rates.txt"%(path_to_data)) as file_in:
    
    #array containing reaction rates and neutrino energy loss rate for the temperature and rhoYe values provided in the table 
    #(nT x rhoYe)=(13x11)
    lam = np.zeros((13,11,3))
    
    #scan every line in the file
    for line in file_in:

        #split terms in the loaded line
        linestr = line.rstrip().split()
        len_linestr = len(linestr)

        #check if the first element of the string is a number or another string
        try:
         check = float(linestr[0])
         is_0 = False
        except:
         check = linestr[0]
         is_0 = True

        #if string
        if(is_0):

          #reactant
          r = linestr[0]

          #product
          p = linestr[1]
          
          #Q-values += mele/mpos c^2
          q1 = linestr[2]
          q2 = linestr[3]

          #type of reaction (forward/reverse)
          rtype = float(linestr[4])
          
          # Determine effective direction of LMP entry
          # If rtype == -1, it describes p -> r
          # If rtype != -1, it describes r -> p

          #initialize indices
          iT = 0
          irho = 0

          #always skip by default
          skip = True
          
        #if line does not begin with string is the table itself
        else:
     
           #load temperature
           T_array[iT] = float(linestr[0])

           #load table and advance indices
           lam[iT,irho,0] = float(linestr[2])
           lam[iT,irho,1] = float(linestr[3])
           lam[iT,irho,2] = float(linestr[4])
           iT += 1
           if(iT==13):

            #load density
            rhoye_array[irho] = float(linestr[1])
            iT = 0
            irho += 1
            evaluate = True

           if(irho==11 and evaluate==True):

            #evaluate rate
            f1 = interp2d((T_array,rhoye_array),lam[:,:,0])
            f2 = interp2d((T_array,rhoye_array),lam[:,:,1])
           
            l1 = f1((T9,np.log10(0.5*rho)))
            l2 = f2((T9,np.log10(0.5*rho)))

            #if reaction timescale is shorter than timescale of interest and if reactant and product are in the list of selected isotopes, don't skip
            if(skip):
             if(r in sps):
              if(p in sps):
               if(tau>1.0/(10**l1+10**l2)):
                skip = False
               else:
                print(f"Skipping standard reaction {r}<->{p} due to low rate")
                R_exclude.append(r)
                P_exclude.append(p)
                
            if(skip==False):
             
                 print(f"Adding standard reactions for {r}<->{p}")
                 
                 # Add Reac1
                 Reac1 = Reaction()          
                 Reac1.tau_rec = 1.0/10**l1
                 Reac1.is_weak = True                      
                 Reac1.R = [r]
                 Reac1.P = [p]
                 for sp in sps:
                   Reac1.multR.append((Reac1.R.count(sp)))
                   Reac1.multP.append((Reac1.P.count(sp)))

                 Reac1.Q = float(q1)
                 Reac1.weak_table = np.copy(lam[:,:,0])
                 Reac1.reac_type = 1
                 Reac1.coeff[:] = 0.0
                 Reac1.mult = 0
                 Reac1.reac_lbl = rtype
                 Reac1.neu = np.copy(lam[:,:,2])

                 if(Reac1.reac_lbl==-1):
                     Reac1.reverse = True
                     Reac1.is_capture = True
                     Reac1.is_beta = False
                 else:
                     Reac1.is_capture = False
                     Reac1.is_beta = True
                
                 net.reactions.append(Reac1)

                 # Add Reac2
                 Reac2 = Reaction()          
                 Reac2.tau_rec = 1.0/10**l2
                 Reac2.is_weak = True                      
                 Reac2.R = [r]
                 Reac2.P = [p]
                 for sp in sps:
                   Reac2.multR.append((Reac2.R.count(sp)))
                   Reac2.multP.append((Reac2.P.count(sp)))

                 Reac2.Q = float(q2)
                 Reac2.weak_table = np.copy(lam[:,:,1])
                 Reac2.reac_type = 1
                 Reac2.coeff[:] = 0.0
                 Reac2.mult = 0
                 Reac2.reac_lbl = rtype
                 Reac2.neu = np.copy(lam[:,:,2])

                 if(Reac2.reac_lbl==-1):
                     Reac2.reverse = True
                     Reac2.is_capture = False
                     Reac2.is_beta = True
                 else:
                     Reac2.is_capture = True
                     Reac2.is_beta = False
     
                 net.reactions.append(Reac2)

#load Jina reaclib data
with open("%s/%s"%(path_to_data,jina_reaclib_file)) as file_in:

    reac_type = 1
    lines = []
    
    for line in file_in:

        linestr = line.rstrip()
        len_linestr = len(linestr)

        if(len_linestr==1 or len_linestr==2):
         reac_type = int(linestr) #get reaction type
          
        if(len_linestr==64):

            R = []
            P = []
            multR = []
            multP = []
            dN = []

            reac_lbl  = linestr[40:52].strip() #reaction label

            Q = float(linestr[52:64]) # Q-value

            flag_reac = []
            for i,sp in enumerate(sps):
             flag_reac.append(False)

            if(reac_type==1): #a-->b
             R.append(linestr[:10])
             P.append(linestr[10:15])
            if(reac_type==2): #a-->b+c
             R.append(linestr[:10])
             P.append(linestr[10:15])
             P.append(linestr[15:20])
            if(reac_type==3): #a-->b+c+d
             R.append(linestr[:10])
             P.append(linestr[10:15])
             P.append(linestr[15:20])
             P.append(linestr[20:25])
            if(reac_type==4): #a+b-->c
             R.append(linestr[:10])
             R.append(linestr[10:15])
             P.append(linestr[15:20])
            if(reac_type==5): #a+b-->c+d
             R.append(linestr[:10])
             R.append(linestr[10:15])
             P.append(linestr[15:20])
             P.append(linestr[20:25]) 
            if(reac_type==6): #a+b-->c+d+e
             R.append(linestr[:10])
             R.append(linestr[10:15])
             P.append(linestr[15:20])
             P.append(linestr[20:25])
             P.append(linestr[25:30])
            if(reac_type==7): #a+b-->c+d+e+f
             R.append(linestr[:10])
             R.append(linestr[10:15])
             P.append(linestr[15:20])
             P.append(linestr[20:25])
             P.append(linestr[25:30])
             P.append(linestr[30:35])
            if(reac_type==8): #a+b+c-->d
             R.append(linestr[:10])
             R.append(linestr[10:15])
             R.append(linestr[15:20])
             P.append(linestr[20:25])
            if(reac_type==9): #a+b+c-->d+e
             R.append(linestr[:10])
             R.append(linestr[10:15])
             R.append(linestr[15:20])
             P.append(linestr[20:25])
             P.append(linestr[25:30])
            if(reac_type==10): #a+b+c+d-->e+f
             R.append(linestr[:10])
             R.append(linestr[10:15])
             R.append(linestr[15:20])
             R.append(linestr[20:25])
             P.append(linestr[25:30])
             P.append(linestr[30:35])
            if(reac_type==11): #a-->b+c+d+e
             R.append(linestr[:10])
             P.append(linestr[10:15])
             P.append(linestr[15:20])
             P.append(linestr[20:25])
             P.append(linestr[25:30])
 
            #list of reactants and products
            for i,rct in enumerate(R):
                R[i] = rct.strip()
            for i,prd in enumerate(P):
                P[i] = prd.strip()
           
            #do we need to consider this reaction? Check if all products and reactants 
            #belong to array of provided isotopes, sps. Also, ignore Jina cases nr. 6, 7, 9, 10, and 11
            if(reac_type==1 or reac_type==2 or reac_type==3 or reac_type==4 or reac_type==5 or reac_type==8):
            
             cnt = 1.0
             for i,rct in enumerate(R):
              if(rct in sps):
                  cnt *= 1
              else:
                  cnt *= 0

             for i,prd in enumerate(P):
              if(prd in sps):
                  cnt *= 1
              else:
                  cnt *= 0
             
            else:

              cnt = 0.0

        #get rate coefficients  
        if(len_linestr==52):
            coeff[0] = float(linestr[:13])
            coeff[1] = float(linestr[13:26])
            coeff[2] = float(linestr[26:39])
            coeff[3] = float(linestr[39:52])

        if(len_linestr==39):
            coeff[4] = float(linestr[:13])
            coeff[5] = float(linestr[13:26])
            coeff[6] = float(linestr[26:39])
            
            #if reaction needs to be taken into account
            if(cnt==1.0):

             #get descruction/production multiplicity of each isotope in sps for the current reaction
             for sp in sps:
               multR.append((R.count(sp)))
               multP.append((P.count(sp)))

             #if reaction satisfies the provided time scale criterion

             tau_rec = jina_tau(coeff,reac_type,T9,rho,reac_lbl)

             if(tau_rec<tau):

               #create Jina reaction object
               Reac = Reaction()
                                     
               #store reaction attributes
               Reac.R = R
               Reac.P = P
               Reac.multR = multR
               Reac.multP = multP
               Reac.Q = Q
               Reac.reac_type = reac_type
               Reac.coeff[:] = np.array(coeff)
               Reac.reac_lbl = reac_lbl[:2]
               Reac.tau_rec = tau_rec 

               #if reaction is reversed, flag it
               if(reac_lbl[-1]=='v'):
                   Reac.reverse = True
               #if reaction is electron capture, flag it
               if(reac_lbl[:2]=='ec'):
                   Reac.ec = True
                   at_least_one_ec = True
                   if(reac_type==4):
                    if(Reac.P[0]=='d'):
                      Reac.is_pep = True

               #if triple alpha
               if(np.max(np.abs(Reac.multR)==3)):
                 if(Reac.R[0]=='he4'):
                   Reac.is_triple_alpha = True

               #add reaction to network

               #check if reaction is already present from tabulated weak rates
               skip=False
               if(Reac.reac_type==1):
                for ir_copy,Reac_copy in enumerate(net.reactions):
                 if(Reac_copy.reac_type==1):
                  if(Reac_copy.P[0]==P[0]):
                   if(Reac_copy.R[0]==R[0]):
                    flag = ir_copy
                    skip = True
           
               #check if reaction was already excluded from tabulated weak rates
               if(Reac.reac_type==1):
                for iw in range(len(R_exclude)):
                  if(P_exclude[iw]==P[0]):
                   if(R_exclude[iw]==R[0]):
                     skip = True                         
              
               if(Reac.reac_type==8 and not Reac.is_triple_alpha): 
                skip=True

               if(skip==False):
                net.reactions.append(Reac)

#count number of reactions (including doubles)
nreac = len(net.reactions)

#copy network
netc = Network()
netc.reactions = net.reactions.copy()

#remove duplicated reactions in copied network and count the reaction multiplicity
for Reac in netc.reactions:
    mult,tau_eff = netc.remove_duplicates(Reac)
    Reac.mult = mult
    Reac.tau_rec = tau_eff

#count undoubled number of reactions
nreacc = len(netc.reactions)

#total number of reactions is not equal to total number of Jina reactions
idx_starting = [0]
#for every considered reaction
for i in range(1,nreacc):
  #get reaction multiplicity
  mult = netc.reactions[i-1].mult
  #get first index of considered reaction in Jina reactions list which includes duplicates
  idx_starting.append(idx_starting[i-1]+mult)

#partition functions

part = {}

#at first, set all partition functions to 0
for el in sps:
 part[el] = np.zeros((24))

#temperature array used to map partition function values
Tpart = [1.0e8, 1.5e8, 2.0e8, 3.0e8, 4.0e8, 5.0e8, 6.0e8, 7.0e8, 
8.0e8, 9.0e8, 1.0e9, 1.5e9, 2.0e9, 2.5e9, 3.0e9, 3.5e9, 
4.0e9, 4.5e9, 5.0e9, 6.0e9, 7.0e9, 8.0e9, 9.0e9, 1.0e10]

#open partition functions file
with open("%s/part.txt"%(path_to_data)) as file_in:
   
    ic = 0
    ie = 0

    for line in file_in:
     
     #ignore file header
     if(ic>3):
      
      linestr = line.rstrip()

      #get element name
      if(ie==0):
         name_ele = line.rstrip()

      #get atomic properties
      if(ie==1): 
          
          extract_part = False
          cff = []
           
          sub = re.findall(r'\d+', line)

          Zi = float(sub[0])
          Ai = float(sub[1])

          #for every species in sps
          for i in range(nsps):
           
           #if isotope matches
           if(A[i]==Ai and Z[i]==Zi):

             extract_part = True
             iele = i
      
      #load partition functions
      if(ie==2):

        if(extract_part): #only if isotope is in list sps
         cff.append([float(x) for x in line.split()])

      #load partition functions
      if(ie==3):

        if(extract_part):
         cff.append([float(x) for x in line.split()])

      #load last line of partition functions
      if(ie==4):

        if(extract_part):

         cff.append([float(x) for x in line.split()])
         #merge lists
         cff = sum(cff, [])
         
         #add partition functions to part dictionary
         part[sps[iele]] = np.log(cff)

      #update ie index
      ie += 1

      #if new element reset index
      if(ie>4):
       ie = 0
     
     #update line counter
     ic += 1

#print network information to terminal
print('\n')
print('rho=%.3e g cm^-3'%(rho))
print('T9=%.2f'%(T9))
print('tau=%.2e s \n'%(tau))
out_str = 'species: '
for sp in sps:
    out_str += sp+' '
print(out_str)

print('#species=%d\n'%(nsps))
for ir,Reac in enumerate(netc.reactions):
 
     Reac.R_copy = Reac.R.copy()

     if(Reac.is_weak):
      if(Reac.reverse):
       if(Reac.is_beta):
        Reac.R_copy[0] += '(beta+)'
       elif(Reac.is_capture):
        Reac.R_copy[0] += '(ec)'
      else:
       if(Reac.is_beta):
        Reac.R_copy[0] += '(beta-)'
       elif(Reac.is_capture):
        Reac.R_copy[0] += '(pc)'
 
     out_str = ''

     len_R = len(Reac.R)
     if(len_R==1):
      out_str += '%s'%(Reac.R_copy[0])
     else:
      for i in range(len_R-1):
        out_str += '%s+'%(Reac.R_copy[i])
      out_str += '%s'%(Reac.R_copy[i+1])

     out_str += '-->'

     len_P = len(Reac.P)
     if(len_P==1):
      out_str += '%s'%(Reac.P[0])
     else:
      for i in range(len_P-1):
        out_str += '%s+'%(Reac.P[i])
      out_str += '%s'%(Reac.P[i+1])

     if(full_output):
      print(ir+1,out_str,'| Q [MeV] =',Reac.Q,'| reverse =',Reac.reverse,'| tau [s] = %.3e'%(Reac.tau_rec))
     else:
      print(ir+1,out_str)

print('#reactions=%d\n'%(len(netc.reactions)))

print('\n')

#write network information to fortran file (target)

#open target file
with open(target, 'r+') as file:
  line = file.readline()
  while line:
      if line.rstrip() == end_target:
          file.truncate(file.tell()) 
          break
      line = file.readline()

#create temporary file
target2 = path_to_target + 'tmp.F90'
f = open(target2,'w')

#create subroutine to extract all the information about the nuclear network
f.write('#ifdef USE_NUCLEAR_NETWORK \n')
f.write('subroutine extract_network_information(lgrid) \n')
f.write('  use source \n')
f.write('  type(locgrid), intent(inout) :: lgrid \n')

f.write('\n')

#load mass number
for i in range(nsps):
    f.write("  lgrid%%A(%d)=%.1f_rp \n"%(i+1,A[i]))

f.write('\n')

#load charge number
for i in range(nsps):
    f.write("  lgrid%%Z(%d)=%.1f_rp \n"%(i+1,Z[i]))

f.write('\n')

#load name species
for i in range(nsps):
    f.write("  lgrid%%name_species(%d)='%s' \n"%(i+1,sps[i]))

f.write('\n')

#load reaction names
for ir,Reac in enumerate(netc.reactions):

    lbl = []
    reacts = Reac.R_copy
    prods = Reac.P

    if(len(reacts)==1):
      lbl.append(reacts[0])
    else:
      for i in range(len(reacts)-1):
        lbl.append(reacts[i]+'+')
      lbl.append(reacts[-1])

    lbl.append('-->')

    if(len(prods)==1):
      lbl.append(prods[0])
    else:
      for i in range(len(prods)-1):
        lbl.append(prods[i]+'+')
      lbl.append(prods[-1])

    lbl = "".join(lbl)

    f.write("  lgrid%%name_reacs(%d)='%s' \n"%(ir+1,lbl))

f.write('\n')

#count number of weak lmp reactions
nweak = 0
for ir,reac in enumerate(netc.reactions):
  if(reac.is_weak and not reac.is_refined):
      nweak += 1

if(use_weak_rates):

 #allocate and initialize the weak table
 f.write('#ifdef USE_LMP_WEAK_RATES \n \n')
 
 f.write('  allocate(lgrid%%weak_table(1:%d,1:13,1:11)) \n'%(nweak))
 f.write('  allocate(lgrid%%weak_neu(1:%d,1:13,1:11)) \n'%(nweak//2)) #only one neutrino energy loss rate per pair of reactions
 f.write('  allocate(lgrid%%neu_rates(1:%d)) \n'%(nweak))
 f.write('\n')
 
 k = 1
 ineu = 0
 for ir,reac in enumerate(netc.reactions):
 
     if(reac.is_weak and not reac.is_refined):
 
         for i in range(13):
           for j in range(11):
 
             f.write('  lgrid%%weak_table(%d,%d,%d)=%.4f_rp \n'%(k,i+1,j+1,reac.weak_table[i,j]))
             
         f.write('\n')
         
         if(k % 2 == 0):
 
          for i in range(13):
            for j in range(11):
 
             f.write('  lgrid%%weak_neu(%d,%d,%d)=%.4f_rp \n'%(ineu+1,i+1,j+1,reac.neu[i,j]))
 
          ineu += 1
          f.write('\n')
     
         k += 1
 
 f.write('#endif \n')
 
 f.write('\n')
 
#load partition functions
f.write('#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES \n \n')
for i in range(24):
    f.write("  lgrid%%temp_part(%d)=%.4f_rp \n"%(i+1,Tpart[i]/1e9))
 
f.write('\n')
 
f.write('  allocate(lgrid%part(1:nspecies,1:24)) \n')
f.write('\n')
 
for i in range(nsps):
 for j in range(24):
    f.write('  lgrid%%part(%d,%d)=%.3e_rp \n'%(i+1,j+1,part[sps[i]][j]))
 f.write('\n')
f.write('#endif \n \n')
 
f.write('end subroutine extract_network_information \n')
 
f.write('\n')

#write subroutine to compute reaction rates from jina
f.write('subroutine compute_jina_rates(T9,R) \n')
f.write('  use source \n')
f.write('  real(kind=rp), intent(in) :: T9 \n')
f.write('  real(kind=rp), dimension(1:nreacs), intent(inout) :: R \n')
f.write('\n')
f.write('  real(kind=rp) :: logT9,cf,e1,e2,e3,e4,e5,tmp,tmpp \n')
f.write('\n')
f.write('  logT9 = log(T9) \n')
f.write('  cf = rp1/T9**fvthirds \n')
f.write('  e1 = T9**tthirds \n')
f.write('  e2 = e1*e1 \n')
f.write('  e3 = e2*e1\n')
f.write('  e4 = e3*e1 \n')
f.write('  e5 = e4*e1 \n')
f.write('  e1 = e1*cf \n')
f.write('  e2 = e2*cf \n')
f.write('  e3 = e3*cf\n')
f.write('  e4 = e4*cf \n')
f.write('  e5 = e5*cf \n')
f.write('  tmp = rp0 \n')
f.write('  tmpp = rp0 \n')
f.write('\n')

ic = 1

#for every reaction in network
for i in range(nreacc):
  
  Reac = netc.reactions[i]
  mult = Reac.mult
  idxs = idx_starting[i]

  if(Reac.is_weak):
    dummy = 1

  #if reaction only appears once
  elif(mult==1):

     Reac = net.reactions[idxs]
     coeff = Reac.coeff 

     lbl = []
     lbl.append('  tmp=%.6e_rp'%(coeff[0]))

     for j in range(1,6):

       if(abs(coeff[j])>0.0):
           if(coeff[j]<0.0):
            lbl.append('  %.6e_rp*e%d'%(coeff[j],j))
           else:
            lbl.append('  +%.6e_rp*e%d'%(coeff[j],j))

     if(abs(coeff[-1])>0.0):
           if(coeff[-1]<0.0):
            lbl.append('  %.6e_rp*logT9'%(coeff[-1]))
           else:
            lbl.append('  +%.6e_rp*logT9'%(coeff[-1]))
  
     for jj in range(len(lbl)-1):
        f.write(lbl[jj]+' & \n')
     f.write(lbl[len(lbl)-1]+'\n')

     f.write('  R(%d)=exp(tmp) \n'%(i+1))
     f.write('\n')

  else:
      
     f.write('  tmp=rp0 \n')

     for k in range(idxs,idxs+mult):

      Reac = net.reactions[k]
      coeff = Reac.coeff

      lbl = []
      lbl.append('  tmpp =%.6e_rp'%(Reac.coeff[0]))

      for j in range(1,6):

       if(abs(coeff[j])>0.0):
           if(coeff[j]<0.0):
            lbl.append('  %.6e_rp*e%d'%(Reac.coeff[j],j))
           else:
            lbl.append('  +%.6e_rp*e%d'%(Reac.coeff[j],j))

      if(abs(coeff[-1])>0.0):
           if(coeff[-1]<0.0):
            lbl.append('  %.6e_rp*logT9'%(Reac.coeff[-1]))
           else:
            lbl.append('  +%.6e_rp*logT9'%(Reac.coeff[-1]))

      for jj in range(len(lbl)-1):
        f.write(lbl[jj]+' & \n')
      f.write(lbl[len(lbl)-1]+'\n')

      f.write('  tmp=tmp+exp(tmpp) \n')

     f.write('  R(%d)=tmp \n \n'%(i+1))

f.write('end subroutine compute_jina_rates \n')

#if the tabulated weak reactions are used, compute the rates using bilinear interpolation
if(use_weak_rates):
 f.write('\n')
 f.write('#ifdef USE_LMP_WEAK_RATES \n')
 f.write('subroutine compute_weak_rates(rhoye,T9,dt,weak_table,weak_neu,neu_rates,R) \n')
 f.write('  use source \n')
 f.write('  real(kind=rp), intent(in) :: rhoye, T9, dt \n')
 f.write('  real(kind=rp), dimension(1:%d,1:13,1:11), intent(in) :: weak_table \n'%(nweak))
 f.write('  real(kind=rp), dimension(1:%d,1:13,1:11), intent(in) :: weak_neu \n'%(nweak//2))
 f.write('  real(kind=rp), dimension(1:%d), intent(inout) :: neu_rates \n'%(nweak))
 f.write('  real(kind=rp), dimension(1:nreacs), intent(inout) :: R \n')
 f.write('\n')
 f.write('\n')
 f.write('  real(kind=rp) :: logrhoye,tmp,u,v,omu,omv,omu_omv,u_omv,v_omu,u_v \n')
 f.write('  real(kind=rp) :: lam_neu,E_neu_avg \n')
 f.write('  integer :: i,idx_logrhoye,idx_T9\n ')
 f.write('\n')
 f.write('  logrhoye = log10(rhoye) \n')
 f.write('  u = rp0 \n')
 f.write('  v = rp0 \n')
 f.write('  idx_T9 = 0 \n')
 f.write('  idx_logrhoye = 0 \n')
 f.write('\n')
 f.write('  do i=1,12 \n')
 f.write('   if((T9>=weak_T9(i)) .and. (T9<weak_T9(i+1))) then \n')
 f.write('    idx_T9 = i \n')
 f.write('    tmp = weak_T9(i) \n')
 f.write('    u = (T9-tmp)/(weak_T9(i+1)-tmp) \n')
 f.write('    exit \n')
 f.write('   end if \n')
 f.write('  end do \n')
 f.write('\n')
 f.write('  do i=1,10 \n')
 f.write('   if((logrhoye>=weak_logrhoye(i)) .and. (logrhoye<weak_logrhoye(i+1))) then \n')
 f.write('    idx_logrhoye = i \n')
 f.write('    tmp = weak_logrhoye(i) \n')
 f.write('    v = (logrhoye-tmp)/(weak_logrhoye(i+1)-tmp) \n')
 f.write('    exit \n')
 f.write('   end if \n')
 f.write('  end do \n')
 f.write('\n')
 f.write('  omu=rp1-u \n')
 f.write('  omv=rp1-v \n')
 f.write('  omu_omv=omu*omv \n')
 f.write('  u_omv=u*omv \n')
 f.write('  v_omu=v*omu \n')
 f.write('  u_v=u*v \n')
 f.write('\n')

 nw = 0
 for ir,reac in enumerate(netc.reactions):

    if(reac.is_weak and not reac.is_refined):
     f.write('  R(%d)= 10**( & \n'%(ir+1))
     f.write('  omu_omv*weak_table(%d,idx_T9,idx_logrhoye) + & \n'%(nw+1))
     f.write('  u_omv*weak_table(%d,idx_T9+1,idx_logrhoye) + & \n'%(nw+1))
     f.write('  v_omu*weak_table(%d,idx_T9,idx_logrhoye+1) + & \n'%(nw+1))
     f.write('  u_v*weak_table(%d,idx_T9+1,idx_logrhoye+1) ) \n'%(nw+1))
     f.write('\n')
     nw += 1
 
 ineu = 0
 ic = 1
 for ir,reac in enumerate(netc.reactions):
 
    if(reac.is_weak and not reac.is_refined):

     if(ir % 2 == 0):

      f.write('  lam_neu = 10**( & \n')
      f.write('  omu_omv*weak_neu(%d,idx_T9,idx_logrhoye) + & \n'%(ineu+1))
      f.write('  u_omv*weak_neu(%d,idx_T9+1,idx_logrhoye) + & \n'%(ineu+1))
      f.write('  v_omu*weak_neu(%d,idx_T9,idx_logrhoye+1) + & \n'%(ineu+1))
      f.write('  u_v*weak_neu(%d,idx_T9+1,idx_logrhoye+1) ) \n'%(ineu+1))
      f.write('\n')

      ineu += 1

     else:

        f.write('  E_neu_avg = lam_neu/(R(%d)+R(%d)) \n'%(ir,ir+1))
        f.write('  neu_rates(%d) = E_neu_avg*R(%d)*dt \n'%(ic,ir))
        f.write('  neu_rates(%d) = E_neu_avg*R(%d)*dt \n'%(ic+1,ir+1))
        f.write('\n') 
        f.write('#ifdef BOOST_NUCLEAR_REACTIONS \n')
        f.write('  neu_rates(%d) = boost_reacs*neu_rates(%d) \n'%(ic,ic))
        f.write('  neu_rates(%d) = boost_reacs*neu_rates(%d) \n'%(ic+1,ic+1))
        f.write('#endif \n')
        f.write('\n')
        ic += 2

 f.write('end subroutine compute_weak_rates \n')

 #compute nuclear neutrino losses
 f.write('\n')
 f.write('subroutine compute_weak_neuloss(rho,Y,neu_rates,dedt) \n')
 f.write('  use source \n')
 f.write('  real(kind=rp), intent(in) :: rho \n')
 f.write('  real(kind=rp), dimension(1:nspecies), intent(in) :: Y \n')
 f.write('  real(kind=rp), dimension(1:%d), intent(in) :: neu_rates \n'%(nweak))
 f.write('  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt \n')
 f.write('\n')
 f.write('  real(kind=rp) :: fac \n')
 f.write('\n')
 f.write('  fac = rho*CONST_NAV_MEV_TO_ERG \n')

 nw = 1
 for ir,reac in enumerate(netc.reactions):
 
    if(reac.is_weak and not reac.is_refined):
      idx = sps.index(reac.R[0])
      f.write('  dedt(%d) = dedt(%d) - fac*Y(%d)*neu_rates(%d) \n'%(ir+1,ir+1,idx+1,nw)) 
      nw += 1

 f.write('\n')
 f.write('end subroutine compute_weak_neuloss \n')
 f.write('#endif \n')
 f.write('\n')

#rescale reverse rates by partition functions of reactants and products
f.write('#ifdef PARTITION_FUNCTIONS_FOR_REVERSE_RATES \n')
f.write('subroutine use_partition_functions(T9,temp_part,part,R) \n')
f.write('  use source \n')
f.write('  real(kind=rp), intent(in) :: T9 \n')
f.write('  real(kind=rp), intent(in) :: temp_part(1:24) \n')
f.write('  real(kind=rp), intent(in) :: part(1:nspecies,1:24) \n')
f.write('  real(kind=rp), dimension(1:nreacs), intent(inout) :: R \n')

f.write('\n')
f.write('  real(kind=rp) :: fac,tmp,tmpp \n')
f.write('  integer :: idx_temp,i \n')
f.write('  real(kind=rp) :: & \n')
for i in range(nsps-1):
    f.write('  part%d, & \n'%(i+1))
f.write('  part%d \n'%(nsps))
f.write('  idx_temp = 1 \n')
f.write('  fac = rp1 \n')
f.write('  tmp = rp1 \n')
f.write('  tmpp = rp1 \n')

f.write('\n')
f.write('  do i=1,23 \n')
f.write('   if((T9>=temp_part(i)) .and. (T9<temp_part(i+1))) then \n')
f.write('    idx_temp = i \n')
f.write('    tmp = temp_part(i) \n')
f.write('    fac = (T9-tmp)/(temp_part(i+1)-tmp) \n')
f.write('    exit \n')
f.write('   end if \n')
f.write('  end do \n')
f.write('\n')

#for every species
for i in range(nsps):
 
 #if the partition function at the highest temperature is larger than 1, interpolate
 if(part[sps[i]][-1]>0.0):
  f.write('  tmp=part(%d,idx_temp) \n'%(i+1))  
  f.write('  tmpp=tmp+fac*(part(%d,idx_temp+1)-tmp) \n'%(i+1))
  f.write('  part%d=exp(tmpp) \n'%(i+1))
 else:
  f.write('  part%d=rp1 \n'%(i+1))
f.write('\n')

#for every reaction in network (duplicates excluded)
for i in range(nreacc):
   
  Reac = netc.reactions[i]

  #if reaction is reversed
  if(Reac.reverse):

   fac0 = '  R(%d)=R(%d)'%(i+1,i+1)
   fac = fac0

   #multiply partition functions of products (how should species multiplicity being handled here?)
   for p in Reac.P:
    jk = np.where(np.asarray(sps) == p)
    fac += '*part%d'%(jk[0][0]+1)

   tmp = '  tmp='
   is_first = True
   #divide by product of partition functions of reactants (how should species multiplicity being handled here?)
   for r in Reac.R:
    if(is_first):
      jk = np.where(np.asarray(sps) == r)
      tmp += 'part%d'%(jk[0][0]+1)
      is_first = False
    else:
      jk = np.where(np.asarray(sps) == r)
      tmp += '*part%d'%(jk[0][0]+1)

   if(fac!=fac0):
       if(tmp!='  tmp='):
        f.write(tmp+'\n')
        f.write(fac+'/tmp'+'\n')
       else:
        f.write(fac+'\n')
       f.write('\n')

f.write('end subroutine use_partition_functions \n')
f.write('#endif \n')
f.write('\n')

#subroutine for computing electron screening corrections (from P. Edelmann's MSc thesis)
f.write('#ifdef USE_ELECTRON_SCREENING \n')
f.write('subroutine screen_rates(rho,T,Y,rates) \n')
f.write('  use source \n')
f.write('  real(kind=rp), intent(in) :: T \n')
f.write('  real(kind=rp), intent(in) :: rho \n')
f.write('  real(kind=rp), intent(in) :: Y(1:nspecies) \n')
f.write('  real(kind=rp), intent(inout) :: rates(1:nreacs) \n')

f.write('\n')

f.write('  real(kind=rp) :: ye,iabar,abar,zbar,Zk,Yk,fw \n')
f.write('  real(kind=rp) :: rhoye,gammap,gammapo4,lngammap,iT,iT3 \n')
f.write('  real(kind=rp) :: gammaeff,Z1,Z2,A1,A2,Ahat,Zprod,Zsum \n')
f.write('  real(kind=rp) :: C,zt,jt,tau,b,b3,b4,b5,b6,Hs,Hw,H \n')
f.write('  real(kind=rp) :: Zsum_5_12,Z1_5_12,Z2_5_12 \n')
f.write('  real(kind=rp) :: Zsum_5_3,Z1_5_3,Z2_5_3 \n')

f.write('\n')

f.write('  Hw = rp0 \n')
f.write('  A1 = rp0 \n')
f.write('  A2 = rp0 \n')
f.write('  A1 = rp0 \n')
f.write('  Ahat = rp0 \n')
f.write('  Z1_5_12 = rp0 \n')
f.write('  Z2_5_12 = rp0 \n')
f.write('  Zsum_5_12 = rp0 \n')
f.write('  Z1_5_3 = rp0 \n')
f.write('  Z2_5_3 = rp0 \n')
f.write('  Zsum_5_3 = rp0 \n')
f.write('  zt = rp0 \n')
f.write('  jt = rp0 \n')
f.write('  C = rp0 \n')
f.write('  tau = rp0 \n')
f.write('  b = rp0 \n')
f.write('  b3 = rp0 \n')
f.write('  b4 = rp0 \n')
f.write('  b5 = rp0 \n')
f.write('  b6 = rp0 \n')
f.write('  Hs = rp0 \n')

f.write('\n')

f.write('  ye = rp0 \n')
f.write('  iabar = rp0 \n')
f.write('  fw = rp0 \n')

for i in range(nsps):
 f.write('  Yk = Y(%d) \n'%(i+1))
 f.write('  Zk = %.1f_rp \n'%(Z[i]))
 f.write('  ye = ye + Yk*Zk \n')
 f.write('  iabar = iabar + Yk \n')
 f.write('  fw = fw + Zk*Zk*Yk \n')
 
f.write('\n')

f.write('  abar = rp1/iabar \n')
f.write('  zbar = ye*abar \n')
f.write('  fw = fw + ye \n')

f.write('\n')
f.write('  iT = rp1/T \n')
f.write('  rhoye = rho*ye \n')
f.write('  gammap = CONST_S1*rhoye**othird*iT \n')
f.write('  gammapo4 = gammap**oquart \n')
f.write('  lngammap = log(gammap) \n')
f.write('  iT3 = iT*iT*iT \n')
f.write('  fw = CONST_S2*sqrt(fw*rho*iT3) \n')
f.write('\n')

for i,Reac in enumerate(netc.reactions):

   reac_type = Reac.reac_type
   Nr = np.array(np.abs(Reac.multR))
   max_Nr = np.max(Nr)
   idx_rct = np.where(Nr>0)[0]

   if(reac_type==4 or reac_type==5):

    if(max_Nr==1):
      Z1 = Z[idx_rct[0]]
      Z2 = Z[idx_rct[1]]
      A1 = A[idx_rct[0]]
      A2 = A[idx_rct[1]]
    if(max_Nr==2):
      Z1 = Z[idx_rct[0]]
      Z2 = Z[idx_rct[0]]
      A1 = A[idx_rct[0]]
      A2 = A[idx_rct[0]]

    if(Z1*Z2>0):

     f.write('  Z1 = %.1f_rp \n'%(Z1))
     f.write('  Z2 = %.1f_rp \n'%(Z2))
     f.write('  Zsum = Z1+Z2 \n')
     f.write('  Zprod = Z1*Z2 \n')
     f.write('  gammaeff = (rp2/Zsum)**othird*Zprod*gammap \n')
     f.write('  if(gammaeff<0.3_rp) then \n')

     f.write('   H = Zprod*fw \n')

     f.write('  else if(gammaeff>0.8_rp) then \n')

     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 

     f.write('  else \n')

     f.write('   Hw = Zprod*fw \n')
     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 
     f.write('   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs \n')

     f.write('  end if \n')
     
     f.write('  rates(%d) = rates(%d)*exp(H) \n'%(i+1,i+1))

     f.write('\n')

   if(Reac.is_triple_alpha): #triple alpha

     #he4+he4
     Z1 = 2.0
     Z2 = 2.0
     A1 = 4.0
     A2 = 4.0

     f.write('  Z1 = %.1f_rp \n'%(Z1))
     f.write('  Z2 = %.1f_rp \n'%(Z2))
     f.write('  Zsum = Z1+Z2 \n')
     f.write('  Zprod = Z1*Z2 \n')
     f.write('  gammaeff = (rp2/Zsum)**othird*Zprod*gammap \n')
     f.write('  if(gammaeff<0.3_rp) then \n')

     f.write('   H = Zprod*fw \n')

     f.write('  else if(gammaeff>0.8_rp) then \n')

     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 

     f.write('  else \n')

     f.write('   Hw = Zprod*fw \n')
     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 
     f.write('   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs \n')

     f.write('  end if \n')
     
     f.write('  rates(%d) = rates(%d)*exp(H) \n'%(i+1,i+1))
    
     f.write('\n')

     #be8+he4
     Z1 = 4.0
     Z2 = 2.0
     A1 = 8.0
     A2 = 4.0

     f.write('  Z1 = %.1f_rp \n'%(Z1))
     f.write('  Z2 = %.1f_rp \n'%(Z2))
     f.write('  Zsum = Z1+Z2 \n')
     f.write('  Zprod = Z1*Z2 \n')
     f.write('  gammaeff = (rp2/Zsum)**othird*Zprod*gammap \n')
     f.write('  if(gammaeff<0.3_rp) then \n')

     f.write('   H = Zprod*fw \n')

     f.write('  else if(gammaeff>0.8_rp) then \n')

     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   H = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 

     f.write('  else \n')

     f.write('   Hw = Zprod*fw \n')
     f.write('   A1 = %.1f_rp \n'%(A1))
     f.write('   A2 = %.1f_rp \n'%(A2))
     f.write('   Ahat = A1*A2/(A1+A2) \n')
     f.write('   Z1_5_12 = Z1**fvtwelfth \n')
     f.write('   Z2_5_12 = Z2**fvtwelfth \n')
     f.write('   Zsum_5_12 = Zsum**fvtwelfth \n')
     f.write('   Z1_5_3 = Z1_5_12*Z1_5_12*Z1_5_12*Z1_5_12 \n')
     f.write('   Z2_5_3 = Z2_5_12*Z2_5_12*Z2_5_12*Z2_5_12 \n')
     f.write('   Zsum_5_3 = Zsum_5_12*Zsum_5_12*Zsum_5_12*Zsum_5_12 \n')
     f.write('   zt = Zsum_5_3 - Z1_5_3 - Z2_5_3 \n')
     f.write('   jt = Zsum_5_12 - Z1_5_12 - Z2_5_12 \n')
     f.write('   C = & \n')
     f.write('   0.896434_rp*gammap*zt - & \n')
     f.write('   3.44740_rp*gammapo4*jt - & \n')
     f.write('   2.996_rp - & \n')
     f.write('   0.5551_rp*(lngammap + fvthirds*log(Zprod/Zsum)) \n') 
     f.write('   tau = CONST_S3*(Zprod*Zprod*Ahat*iT)**othird \n')
     f.write('   b = rp3*gammaeff/tau \n')
     f.write('   b3 = b*b*b \n')
     f.write('   b4 = b3*b \n')
     f.write('   b5 = b4*b \n')
     f.write('   b6 = b5*b \n')
     f.write('   Hs = C - othird*tau*(rp5/rp32*b3-0.014_rp*b4-0.0128_rp*b5) - & \n')
     f.write('   gammaeff*(0.0055_rp*b4-0.0098_rp*b5+0.0048_rp*b6) \n') 
     f.write('   H = rp2*(0.8_rp-gammaeff)*Hw + rp2*(gammaeff-0.3_rp)*Hs \n')

     f.write('  end if \n')
     
     f.write('  rates(%d) = rates(%d)*exp(H) \n'%(i+1,i+1))

     f.write('\n')

f.write('end subroutine screen_rates \n')
f.write('#endif \n')
f.write('\n')

#get matrix of species muliplicities
M = np.zeros((nreacc,nsps))

for i,Reac in enumerate(netc.reactions):
 for j,sp in enumerate(sps): 
    M[i,j] = Reac.multP[j]-Reac.multR[j]

#compute rhs of network
lam = {}

#for every reaction in network (no doubles)
for i,Reac in enumerate(netc.reactions):

    lam[i] = ['  lam%d='%(i+1)]

    reac_type = Reac.reac_type
    fac = 1.0
    Nr = np.array(np.abs(Reac.multR))
    max_Nr = np.max(Nr)
    idx_rct = np.where(Nr>0)[0]

    #if beta decays, ec, or photodisintegration
    if(reac_type==1 or reac_type==2 or reac_type==3):
        if(Reac.reac_lbl=='ec'):
         lam[i].append('rho*ye*Y%d*R%d'%(np.argmax(Nr)+1,i+1))
        else:
         lam[i].append('Y%d*R%d'%(np.argmax(Nr)+1,i+1))

    #if two-body reaction
    if(reac_type==4 or reac_type==5):
     if(Reac.reac_lbl=='ec'): #pep
      if(Reac.is_pep):
       lam[i].append('rph*rho2*ye*Y%d*Y%d*R%d'%(np.argmax(Nr)+1,np.argmax(Nr)+1,i+1))
     else:
      if(max_Nr==1):
       lam[i].append('rho*Y%d*Y%d*R%d'%(idx_rct[0]+1,idx_rct[1]+1,i+1))
      if(max_Nr==2):
       lam[i].append('rph*rho*Y%d*Y%d*R%d'%(idx_rct[0]+1,idx_rct[0]+1,i+1))
     
    #if three-body reaction (case "a+a+b-->..." is neglected for simplicity)
    if(reac_type==8):
     if(max_Nr==1):
      lam[i].append('rho2*Y%d*Y%d*Y%d*R%d'%(idx_rct[0]+1,idx_rct[1]+1,idx_rct[2]+1,i+1))
     if(max_Nr==3):
      lam[i].append('osixth*rho2*Y%d*Y%d*Y%d*R%d'%(idx_rct[0]+1,idx_rct[0]+1,idx_rct[0]+1,i+1))

    lam[i] = "".join(lam[i])

#check which isotopes and where they enter the system of ODEs
flagged = np.zeros((nreacc,nsps))

for i,reac in enumerate(netc.reactions):

    reac_type = reac.reac_type
    fac = 1.0
    nr = np.array(np.abs(reac.multR))
    max_nr = np.max(nr)
    idx_rct = np.where(nr>0)[0]

    if(reac_type==1 or reac_type==2 or reac_type==3):
      ic  = np.argmax(nr)
      if(reac.reac_lbl=='ec'):
       flagged[i,:] = 1
      else:
       flagged[i,ic] = 1

    if(reac_type==4 or reac_type==5):
     if(max_nr==1):
      flagged[i,idx_rct[0]] = 1
      flagged[i,idx_rct[1]] = 1
     if(max_nr==2):
      flagged[i,idx_rct[0]] = 1
     if(reac.reac_lbl=='ec'): #pep
      flagged[i,:] = 1

    if(reac_type==8):
     if(max_nr==1):
      flagged[i,idx_rct[0]] = 1
      flagged[i,idx_rct[1]] = 1
      flagged[i,idx_rct[2]] = 1
     if(max_nr==3):
      flagged[i,idx_rct[0]] = 1

#compute jacobian of system of ODEs
f.write('subroutine compute_network_residuals(Y,rho,R,res,jac,dedt,return_jac,return_dedt) \n')
f.write('  use source \n')
f.write('  real(kind=rp), dimension(1:nspecies), intent(in) :: Y \n')
f.write('  real(kind=rp), intent(in) :: rho \n')
f.write('  real(kind=rp), dimension(1:nreacs), intent(in) :: R \n')
f.write('  real(kind=rp), dimension(1:nspecies), intent(inout) :: res \n')
f.write('  real(kind=rp), dimension(1:nspecies,1:nspecies), intent(inout) :: jac \n')
f.write('  real(kind=rp), dimension(1:nreacs), intent(inout) :: dedt \n')
f.write('  logical, intent(in) :: return_jac \n')
f.write('  logical, intent(in) :: return_dedt \n')
f.write('\n')

f.write('  real(kind=rp) :: & \n')
f.write('  ye, & \n')
for i in range(nreacc):
 f.write('  lam%d, & \n'%(i+1))
for i in range(nreacc):
 f.write('  R%d, & \n'%(i+1))
for i in range(nsps):
 f.write('  Y%d, & \n'%(i+1))
for i in range(nreacc):
 for j in range(nsps):
  if(flagged[i,j]!=0): 
   f.write('  dlam_dY_%d_%d, & \n'%(i+1,j+1))
f.write('  rho2 \n')
f.write('\n')
f.write('  rho2 = rho*rho \n')
f.write('  ye=rp1 \n')
f.write('\n')

for i in range(nreacc):
 f.write('  R%d=R(%d) \n'%(i+1,i+1))
f.write('\n')

for i in range(nsps):
 f.write('  Y%d=Y(%d) \n'%(i+1,i+1))
f.write('\n')

if(at_least_one_ec):
 f.write('  ye = & \n')
 for i in range(nsps-1):
  f.write('  +Y%d*%.1f_rp & \n'%(i+1,Z[i]))
 f.write('  +Y%d*%.1f_rp  \n'%(len(sps),Z[len(sps)-1]))
 f.write('\n')

#initialize lambdas
for i in range(nreacc):
    f.write(lam[i]+'\n')
f.write('\n')

#compute rhs
for i in range(nsps):
    res = []
    res.append('  res(%d)='%(i+1))
    for ir,Reac in enumerate(netc.reactions):
        m = -M[ir,i] 
        if(m!=0):
         if(m==-1):
          res.append('  -lam%d'%(ir+1))
         elif(m==1):
          res.append('  +lam%d'%(ir+1))
         else:
          if(m>0):
           res.append('  +%s*lam%d'%(number[np.abs(m)],ir+1))
          else:
           res.append('  -%s*lam%d'%(number[np.abs(m)],ir+1))

    if(len(res)>1):

     for j in range(len(res)-1):
         f.write(res[j]+' & \n')
 
     f.write(res[len(res)-1]+'\n')

    else:
    
     f.write(res[0]+'rp0 \n')
         
    f.write('\n')

#compute jacobian
f.write('  if(return_jac) then \n')
f.write('\n')

for i,reac in enumerate(netc.reactions):

    reac_type = reac.reac_type
    fac = 1.0
    nr = np.array(np.abs(reac.multR))
    max_nr = np.max(nr)
    idx_rct = np.where(nr>0)[0]

    if(reac_type==1 or reac_type==2 or reac_type==3):
      ic  = np.argmax(nr)
      if(reac.reac_lbl=='ec'):
       for isps,sp in enumerate(sps):
        if(ic!=isps):
         f.write('   dlam_dY_%d_%d=rho*%.1f_rp*Y%d*R%d \n'%(i+1,isps+1,Z[isps],ic+1,i+1))
        else:
         f.write('   dlam_dY_%d_%d=rho*R%d*(Y%d*%.1f_rp+ye) \n'%(i+1,ic+1,i+1,ic+1,Z[ic]))
      else:
       f.write('   dlam_dY_%d_%d=R%d \n'%(i+1,ic+1,i+1))

    if(reac_type==4 or reac_type==5):

     if(max_nr==1):
      f.write('   dlam_dY_%d_%d=rho*Y%d*R%d \n'%(i+1,idx_rct[0]+1,idx_rct[1]+1,i+1))
      f.write('   dlam_dY_%d_%d=rho*Y%d*R%d \n'%(i+1,idx_rct[1]+1,idx_rct[0]+1,i+1))
     if(max_nr==2):

      if(reac.reac_lbl=='ec'): #pep
       ic  = np.argmax(nr)
       for isps,sp in enumerate(sps):
        if(ic!=isps):
         f.write('   dlam_dY_%d_%d=rph*rho2*%.1f_rp*Y%d*Y%d*R%d \n'%(i+1,isps+1,Z[isps],ic+1,ic+1,i+1))
        else:
         f.write('   dlam_dY_%d_%d=rph*rho2*Y%d*(rp2*ye+Y%d*%.1f)*R%d \n'%(i+1,ic+1,ic+1,ic+1,Z[ic],i+1))
      else:
       f.write('   dlam_dY_%d_%d=rho*Y%d*R%d \n'%(i+1,idx_rct[0]+1,idx_rct[0]+1,i+1))

    if(reac_type==8):
     if(max_nr==1):
      f.write('   dlam_dY_%d_%d=rho2*Y%d*Y%d*R%d \n'%(i+1,idx_rct[0]+1,idx_rct[1]+1,idx_rct[2],i+1))
      f.write('   dlam_dY_%d_%d=rho2*Y%d*Y%d*R%d \n'%(i+1,idx_rct[1]+1,idx_rct[0]+1,idx_rct[2],i+1))
      f.write('   dlam_dY_%d_%d=rho2*Y%d*Y%d*R%d \n'%(i+1,idx_rct[2]+1,idx_rct[0]+1,idx_rct[1],i+1))
     if(max_nr==3):
      f.write('   dlam_dY_%d_%d=rph*rho2*Y%d*Y%d*R%d \n'%(i+1,idx_rct[0]+1,idx_rct[0]+1,idx_rct[0]+1,i+1))

f.write('\n')

number = {
2 : 'rp2',
3 : 'rp3'}

flagged_jac = np.zeros((nsps,nsps))

for i in range(nsps):

    for k in range(nsps):

     res = []
     res.append('   jac(%d,%d)='%(i+1,k+1))
     for ir,Reac in enumerate(netc.reactions):
        if(flagged[ir,k]!=0):
         m = -M[ir,i] 
         if(m!=0):
          if(m==-1):
           res.append('   -dlam_dY_%d_%d'%(ir+1,k+1))
          elif(m==1):
           res.append('   +dlam_dY_%d_%d'%(ir+1,k+1))
          else:
           if(m>0):
            res.append('   +%s*dlam_dY_%d_%d'%(number[np.abs(m)],ir+1,k+1))
           else:
            res.append('   -%s*dlam_dY_%d_%d'%(number[np.abs(m)],ir+1,k+1))
     if(len(res)>1):
      flagged_jac[i,k] = 1
      for j in range(len(res)-1):
        f.write(res[j]+' & \n')

      f.write(res[len(res)-1]+2*'\n')

for i in range(nsps):
 if(flagged_jac[i,i]==0):
   f.write('   jac(%d,%d)=rp0 \n'%(i+1,i+1))
   f.write('\n')

f.write('  end if \n')
f.write('\n')
f.write('  if(return_dedt) then \n')
f.write('\n')
for i,Reac in enumerate(netc.reactions):
    f.write('   dedt(%d)=%.6e_rp*lam%d*rho \n'%(i+1,Reac.Q*Nav_mev_to_erg,i+1))
f.write('\n')
f.write('  end if \n')
f.write('\n')
f.write('end subroutine compute_network_residuals \n')
f.write('#endif \n')
f.write('\n')

#==============#

f.write('#ifdef SAVE_SPECIES_FLUXES \n')
f.write('subroutine species_residuals_per_reac(Y,rho,R,Xds) \n')
f.write('  use source \n')
f.write('  real(kind=rp), dimension(1:nspecies), intent(in) :: Y \n')
f.write('  real(kind=rp), intent(in) :: rho \n')
f.write('  real(kind=rp), dimension(1:nreacs), intent(in) :: R \n')
f.write('  real(kind=rp), dimension(1:nspecies,1:nreacs), intent(inout) :: Xds \n')
f.write('\n')

f.write('  real(kind=rp) :: & \n')
f.write('  ye, & \n')
for i in range(nreacc):
 f.write('  lam%d, & \n'%(i+1))
for i in range(nreacc):
 f.write('  R%d, & \n'%(i+1))
for i in range(nsps):
 f.write('  Y%d, & \n'%(i+1))
f.write('  rho2 \n')
f.write('\n')
f.write('  rho2 = rho*rho \n')
f.write('  ye=rp1 \n')
f.write('\n')

for i in range(nreacc):
 f.write('  R%d=R(%d) \n'%(i+1,i+1))
f.write('\n')

for i in range(nsps):
 f.write('  Y%d=Y(%d) \n'%(i+1,i+1))
f.write('\n')

if(at_least_one_ec):
 f.write('  ye = & \n')
 for i in range(nsps-1):
  f.write('  +Y%d*%.1f_rp & \n'%(i+1,Z[i]))
 f.write('  +Y%d*%.1f_rp  \n'%(len(sps),Z[len(sps)-1]))
 f.write('\n')

#initialize lambdas
for i in range(nreacc):
    f.write(lam[i]+'\n')
f.write('\n')

#compute rhs
for i in range(nsps):

    for ir,Reac in enumerate(netc.reactions):

        m = -M[ir,i] 
        if(m!=0):
         if(m==-1):
          f.write('  Xds(%d,%d) = lam%d \n'%(i+1,ir+1,ir+1))
         elif(m==1):
          f.write('  Xds(%d,%d) = -lam%d \n'%(i+1,ir+1,ir+1))
         else:
          if(m>0):
           f.write('  Xds(%d,%d) = -%s*lam%d \n'%(i+1,ir+1,number[np.abs(m)],ir+1))
          else:
           f.write('  Xds(%d,%d) = %s*lam%d \n'%(i+1,ir+1,number[np.abs(m)],ir+1))
        else:
         f.write('  Xds(%d,%d) = rp0 \n'%(i+1,ir+1))    

f.write('\n')

f.write('end subroutine species_residuals_per_reac \n')
f.write('#endif \n')
f.write('\n')

#==============#

f.close()

data = data2 = ""

with open(target) as fp:
    data = fp.read()

with open(target2) as fp:
    data2 = fp.read()

data += "\n"
data += data2

with open(target, 'w') as fp:
    fp.write(data)

os.remove(target2)

#==============#

