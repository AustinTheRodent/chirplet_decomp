#t, fc, alpha1, alpha2, phi

import subprocess
import numpy

n=100

def getstats():
	data=[0,0,0,0,0]
	outp=subprocess.check_output(["octave","optimized_decomposition_1sig.m"])
	outp=outp.decode().split("\n")
	for i in outp:
		if len(i)>1:
			j=i.split(" = ")
			if j[0]=="b":
				data[0]=float(j[1])
			if j[0]=="a":
				data[1]=float(j[1])
			if j[0]=="alpha1_":
				data[2]=float(j[1])
			if j[0]=="alpha2_":
				data[3]=float(j[1])
			if j[0]=="phi_":
				data[4]=float(j[1])
	return (data)

t=[]
fc=[]
alpha1=[]
alpha2=[]
phi=[]

for i in range(n):
	data=getstats()
	t.append(data[0])
	fc.append(data[1])
	alpha1.append(data[2])
	alpha2.append(data[3])
	phi.append(data[4])
	print(i+1,"/",n," samples complete")
	
t=numpy.array(t)
fc=numpy.array(fc)
alpha1=numpy.array(alpha1)
alpha2=numpy.array(alpha2)
phi=numpy.array(phi)

print("t=",numpy.format_float_scientific(numpy.mean(t)),"\tstdev=",numpy.format_float_scientific(numpy.math.sqrt(numpy.var(t))))
print("fc=",numpy.format_float_scientific(numpy.mean(fc)),"\tstdev=",numpy.format_float_scientific(numpy.math.sqrt(numpy.var(fc))))
print("alpha1=",numpy.format_float_scientific(numpy.mean(alpha1)),"\tstdev=",numpy.format_float_scientific(numpy.math.sqrt(numpy.var(alpha1))))
print("alpha2=",numpy.format_float_scientific(numpy.mean(alpha2)),"\tstdev=",numpy.format_float_scientific(numpy.math.sqrt(numpy.var(alpha2))))
print("phi=",numpy.format_float_scientific(numpy.mean(phi)),"\tstdev=",numpy.format_float_scientific(numpy.math.sqrt(numpy.var(phi))))
