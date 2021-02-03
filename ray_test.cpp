#include <iostream>
#include <ostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <string>
class Vector3D
{
private:
public:
    float x,y,z;
    Vector3D();
    Vector3D(float _x, float _y, float _z);
    Vector3D crossProduct(const Vector3D& v);
    float dotProduct(const Vector3D& v);
    std::string toString();
    ~Vector3D();
};

Vector3D::Vector3D()
{
    x = 0;
    y = 0;
    z = 0;
}

Vector3D::Vector3D(float _x, float _y, float _z)
{
    x = _x;
    y = _y;
    z = _z;
}

Vector3D operator-(const Vector3D& a, const Vector3D& b) {
    return Vector3D(a.x - b.x, a.y - b.y, a.z - b.z);
}

Vector3D operator+(const Vector3D& a, const Vector3D& b) {
    return Vector3D(a.x + b.x, a.y + b.y, a.z + b.z);
}

Vector3D operator*(const Vector3D& a, const float s) {
    return Vector3D(a.x * s, a.y * s, a.z * s);
}

Vector3D Vector3D::crossProduct(const Vector3D& a) {
    
    /* 
        assign c1 = (a2*b3) - (a3*b2)
        assign c2 = (a3*b1) - (a1*b3)
        assign c3 = (a1*b2) - (a2*b1)
    */
    return Vector3D((y * a.z) - (z * a.y), (y * a.x) - (x * a.z), (x * a.y) - (y * a.x));
}

float Vector3D::dotProduct(const Vector3D& a) {
    return (x * a.x) + (y * a.y) + (z * a.z);
}

std::string Vector3D::toString() {
    std::stringstream ss;
    ss << '(' << x << ',' << y << ',' << z << ')';
    return ss.str();
}

Vector3D::~Vector3D(){}

class Triangle
{
public:
    Vector3D vertex0, vertex1, vertex2;
    Triangle();
    Triangle(Vector3D v0, Vector3D v1, Vector3D v2);
};

Triangle::Triangle(){}
Triangle::Triangle(Vector3D v0, Vector3D v1, Vector3D v2) {
    vertex0 = v0;
    vertex1 = v1;
    vertex2 = v2;
}



Triangle* quadToTri(Vector3D a, Vector3D b, Vector3D c, Vector3D d){
    Triangle* tri_pair = (Triangle*) malloc(sizeof(Triangle) * 2);
    tri_pair[0] = Triangle(a,b,c);
    tri_pair[1] = Triangle(a,d,c);
    return tri_pair;
}

std::vector<Triangle> readOfftoTris(std::string path) {
    std::string line;
    std::ifstream file(path.c_str());
    std::vector<std::string> lines;
    if( file.is_open()) {
        while( getline(file,line) ) {
            lines.push_back(line);
        }
        file.close();
    } else {
        std::cerr << "Error reading file" << std::endl;
    }

    if(lines[0].compare("OFF") != 0) {
        std::cerr << "Error: \"" << path << "\" is not a valid OFF file" << std::endl;
    }
    std::stringstream temp_ss(lines[1]);
    std::string temp_str;
    
    int num_points;
    getline(temp_ss,temp_str,' ');
    num_points = atoi(temp_str.c_str());
    
    std::vector<std::string>::iterator points_start = lines.begin() + 2;
    std::vector<std::string>::iterator points_end = lines.begin() + 2 + num_points;
    std::vector<Vector3D> points;
    
    for(std::vector<std::string>::iterator point = points_start; point != points_end; point++) {
        float coords[3];
        std::stringstream point_ss(point->c_str());

        for(int i = 0; i < 3; i++) {
            getline(point_ss,temp_str,' ');
            coords[i] = atof(temp_str.c_str());
        } 

        points.push_back(Vector3D(coords[0],coords[1],coords[2]));
    } 

    std::vector<Triangle> tris;

    for(std::vector<std::string>::iterator poly = points_end; poly != lines.end(); poly++) {
        int verts[4];
        std::stringstream poly_ss(poly->c_str());
        
        getline(poly_ss,temp_str,' ');
        int vert_count = atoi(temp_str.c_str());
        if (vert_count > 4) {
            std::cerr << "Error, currently only meshes with tris and quads are supported. Please convert your mesh first" << std::endl;
        }
        
        for (int i = 0; i < vert_count; i++)
        {
            getline(poly_ss,temp_str,' ');
            verts[i] = atoi(temp_str.c_str());
        }
        
        switch (vert_count)
        {
        case 3:
            tris.push_back(Triangle(points[verts[0]], points[verts[1]], points[verts[2]]));
            break;
        case 4:
            // convert quad to tris
            Triangle* pair = quadToTri(points[verts[0]], points[verts[1]], points[verts[2]], points[verts[3]]);
            tris.push_back(pair[0]);
            tris.push_back(pair[1]);
            // I think I need this? I should prob just use smart pointers instead of raw pointers like a C caveman
            // this is C++, we have the technology
            free(pair);
            break;
        }
    }



}



float RayIntersectsTriangle(Vector3D rayOrigin, 
                           Vector3D rayVector, 
                           Triangle* inTriangle,
                           Vector3D& outIntersectionPoint)
{
    const float EPSILON = 0.0000001;
    Vector3D vertex0 = inTriangle->vertex0;
    Vector3D vertex1 = inTriangle->vertex1;  
    Vector3D vertex2 = inTriangle->vertex2;
    Vector3D edge1, edge2, h, s, q;
    float a,f,u,v;
    edge1 = vertex1 - vertex0;
    edge2 = vertex2 - vertex0;
    h = rayVector.crossProduct(edge2);
    a = edge1.dotProduct(h);
    if (a > -EPSILON && a < EPSILON)
        return -1;    // This ray is parallel to this triangle.
    f = 1.0/a;
    s = rayOrigin - vertex0;
    u = f * s.dotProduct(h);
    if (u < 0.0 || u > 1.0)
        return -1;
    q = s.crossProduct(edge1);
    v = f * rayVector.dotProduct(q);
    if (v < 0.0 || u + v > 1.0)
        return -1;
    // At this stage we can compute t to find out where the intersection point is on the line.
    float t = f * edge2.dotProduct(q);
    if (t > EPSILON) // ray intersection
    {
        outIntersectionPoint = rayOrigin + rayVector * t;
        return t;
    }
    else // This means that there is a line intersection but not a ray intersection.
        return -1;
}

/* 
    basic 1 sample 0 bounce tracer
    trace_rays:
        for ray in rays:
            if any(rayTriangleIntersection(ray,tri) for tri in tris):
                draw white
            else:
                draw black
    
    intermediate s sample b bounce diffuse tracer
    trace_rays:
        for ray in rays:
            repeat s times:
            intersections = [rayTriangleIntersection(ray,tri) for tri in tris if t > 0]
            if no intersections:
                draw sky/bg color
            else:
                if b = 0:
                    draw color of min(t of intersections)
                else:
                    new_ray = min(t of intersections), reflect ray over normal of tri (or random dir for diffuse)
                    trace_rays(r,tris,s,b-1)
            

*/

int main(int argc, char const *argv[])
{
    Triangle t1;
    t1.vertex0 = Vector3D(0,0,1);
    t1.vertex1 = Vector3D(0,1,0);
    t1.vertex2 = Vector3D(1,0,0);

    Vector3D rayOrigin(0,0,0);
    Vector3D rayVector(1,1,1);
    Vector3D intersectionPoint;

    std::cout << "Ray Origin: " << rayOrigin.toString() << std::endl;
    std::cout << "Ray Direction: " << rayVector.toString() << std::endl;
    
    std::cout << "Triangle:" << std::endl;
    std::cout << "V1: " << t1.vertex0.toString() << std::endl;
    std::cout << "V2: " << t1.vertex1.toString() << std::endl;
    std::cout << "V2: " << t1.vertex2.toString() << std::endl;

    bool intersection = RayIntersectsTriangle(rayOrigin,rayVector,&t1,intersectionPoint);

    std::cout << "Intersection: " << intersection << " at " << intersectionPoint.toString() << std::endl;

    return 0;
}
