
import numpy as np

N = 8

a = 32.0/2**16

for i in range(2**N):
  print(np.exp(-(2**(16-N))*a*float(i)))

#print(np.exp(0))
