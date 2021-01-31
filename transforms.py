import math
import numpy as np



def rotate(val,axis='z',mode='d'):
        if mode == 'd':
            val = math.radians(val)
        return axis_definitions[axis](val)
        

def rotateX(val): #value always in radians
    return np.array([[1,0,0,0],[0,math.cos(val),-math.sin(val),0],[0,math.sin(val),math.cos(val),0],[0,0,0,1]])

def rotateZ(val): #value always in radians
    return np.array([[math.cos(val),-math.sin(val),0,0],[math.sin(val),math.cos(val),0,0],[0,0,1,0],[0,0,0,1]])

def rotateY(val): #value always in radians
    return np.array([[math.cos(val),0,math.sin(val),0],[0,1,0,0],[-math.sin(val),0,math.cos(val),0],[0,0,0,1]])

def translate(l=[],x=0,y=0,z=0):
    if l == []:
        l = [x,y,z]
    return np.array([[1,0,0,l[0]],[0,1,0,l[1]],[0,0,1,l[2]],[0,0,0,1]])

axis_definitions = {
    'x' : rotateX,
    'y' : rotateY,
    'z' : rotateZ
}