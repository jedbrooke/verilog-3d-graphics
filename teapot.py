import sys
import numpy as np
import math
import transforms
import pygame

class Screen():
    def __init__(self,vw=80,vh=24,mode="g"):
        self.vw = vw
        self.vh = vh
        self.Mviewport = np.array([[vw/2,0,0,(vw-1)/2],[0,vh/2,0,(vh-1)/2],[0,0,1,0],[0,0,0,1]])
        self.mode = mode
        if self.mode == "g":
            self.screen = pygame.display.set_mode((vw, vh))
            self.screen.fill((0, 0, 0))
        if self.mode == "t":
            self.pixels = [[False for i in range(self.vw)] for i in range(self.vh)]
        self.drawnLines = []

    def setCamera(self,camera):
        self.camera = camera

    def draw(self):
        if self.mode == "g":
            pygame.display.flip()
        if self.mode == "t":
            for row in self.pixels:
                for x in row:
                    print(chr(9608),end="") if x else print(' ',end="")
                print("")
    
    def clear(self):
        self.pixels = [[False for i in range(self.vw)] for i in range(self.vh)]

    def drawObject(self,obj):
        modelview = np.matmul(self.camera.getMcam(),obj.model_transform)
        bigM = np.matmul(self.Mviewport,np.matmul(self.camera.getMproj(),modelview))
        projpoints = np.matmul(bigM,obj.points)
        for poly in obj.polys:
            lines = [(poly[i],poly[i+1]) for i in range(len(poly) - 1)] + [(poly[-1],poly[0])]
            for l in lines:
                p = projpoints[:,l[0]]
                q = projpoints[:,l[1]]
                self.drawLine(p[0]/p[3],p[1]/p[3],q[0]/q[3],q[1]/p[3])


    def drawLine(self,x1,y1,x2,y2):
        if any([l[0] == x1 and l[1] == y1 and l[2] == x2 and l[3] == y2 for l in self.drawnLines]): #avoid 
            return
        if self.mode == "g":
            pygame.draw.aaline(self.screen, (255, 255, 255), (x1,y1),(x2,y2))
        if self.mode == "t":
            dx = x2-x1
            dy = y2-y1
            dE = 2*dy
            dNE = 2*(dy-dx)
            d = 2*dy - dx
            y = y1
            for x in range(int(x1),int(x2)+1):
                self.setPixel(x,int(y))
                if d > 0:
                    d += dNE
                    y += 1
                else:
                    d += dE
        self.drawnLines.append([x1,y1,x2,y2])
    
    def setPixel(self,x,y):
        if x >= self.vw or y >= self.vh:
            return
        self.pixels[y][x] = True

class Model():
    def __init__(self,points=[],polys=[]):
        self.points = points
        self.polys = polys
        self.model_transform = np.identity(4)
        

    def transform(self,mat):
        self.model_transform = np.matmul(mat,self.model_transform)


class Camera():
    def __init__(self,x=0,y=0,z=-2,lx=0,ly=0,lz=0,n=0.1,f=5,l=-1,r=1,t=1,b=-1):
        self.transformation = np.identity(4)
        self._Peye = np.array([x,y,z,1])
        self._Pref = np.array([lx,ly,lz,1])
        self._Vup = np.array([0,1,0,0])
        self.n = n #near plane
        self.f = f #far plane
        self.l = l #x-left
        self.r = r #x-right
        self.t = t #y-top
        self.b = b #y-bottom


    def transform(self,mat):
        self.transformation = np.matmul(mat,self.transformation)
        self._Peye = np.matmul(self.transformation,self._Peye)

    def getMcam(self):
        k = (self._Peye - self._Pref)
        k = k / np.linalg.norm(k)
        i = np.cross(self._Vup[:3],k[:3])
        i = i / np.linalg.norm(i)
        j = np.cross(k[:3],i)
        i = np.concatenate((i,np.array([0])))
        j = np.concatenate((j,np.array([0])))
        rotmat = np.array([i,j,k,[0,0,0,1]]) #already inversed
        transmat = transforms.translate(-self._Peye[:3]) #already inversed
        return np.matmul(rotmat,transmat)
    
    def getMproj(self):
        n,f,l,r,t,b = self.n,self.f,self.l,self.r,self.t,self.b
        return np.array([[(2*n)/(r-l),0,(r+l)/(r-l),0],[0,(2*n)/(t-b),(t+b)/(t-b),0],[0,0,(n+f)/(n-f),(2*n*f)/(n-f)],[0,0,-1,0]])



def printerr(msg,*args,**kwargs):
    print(msg,file=sys.stderr,*args,**kwargs)

def loadoff(path):
    lines = [line.strip() for line in open(path,"r")]
    if lines[0] != "OFF":
        printerr("Error: file is not an OFF file")
        sys.exit(1)

    num_points = [int(f) for f in lines[1].split()][0]
    points = np.array([[float(p) for p in line.split()] + [1] for line in lines[2:2+num_points]]).T
    polys = [[int(d) for d in line.split()[1:]] for line in lines[2+num_points:]]
    return Model(points,polys)

if __name__ == "__main__":
    s = Screen(640,480)
    z = -6
    c = Camera(x=-3,z=z,n=z+0.1)
    s.setCamera(c)
    c.transform(transforms.rotateX(math.radians(90)))
    teapot = loadoff("teapot.off")
    s.drawObject(teapot)
    s.draw()
    running = True
    while running:
        event = pygame.event.poll()
        if event.type == pygame.QUIT:
            running = 0
        pygame.display.flip()
