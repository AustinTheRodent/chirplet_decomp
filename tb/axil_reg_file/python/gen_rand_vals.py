
import sys
import random

def main():
  is_signed = False
  for i in range(len(sys.argv)):
    if sys.argv[i] == "-s": # vector dwidth [bits]
      sym_len = int(sys.argv[i+1])
    elif sys.argv[i] == "-n": # number of samples
      num_samples = int(sys.argv[i+1])
    elif sys.argv[i] == "-sgn": # output fname
      is_signed = True

  if is_signed == False:
    for i in range(num_samples):
      print("%i" % random.randrange(0,2**sym_len,1))
  else:
    for i in range(num_samples):
      print("%i" % random.randrange(-2**(sym_len-1),2**(sym_len-1),1))

if __name__ == "__main__":
  main()
