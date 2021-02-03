class Vector3D
{
private:
public:
    float x,y,z;
    Vector3D();
    Vector3D(float _x, float _y, float _z);
    Vector3D crossProduct(const Vector3D& v);
    float dotProduct(const Vector3D& v);
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

Vector3D::~Vector3D(){}

struct Triangle
{
    Vector3D vertex0, vertex1, vertex2;
};
typedef struct Triangle Triangle;




bool RayIntersectsTriangle(Vector3D rayOrigin, 
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
        return false;    // This ray is parallel to this triangle.
    f = 1.0/a;
    s = rayOrigin - vertex0;
    u = f * s.dotProduct(h);
    if (u < 0.0 || u > 1.0)
        return false;
    q = s.crossProduct(edge1);
    v = f * rayVector.dotProduct(q);
    if (v < 0.0 || u + v > 1.0)
        return false;
    // At this stage we can compute t to find out where the intersection point is on the line.
    float t = f * edge2.dotProduct(q);
    if (t > EPSILON) // ray intersection
    {
        outIntersectionPoint = rayOrigin + rayVector * t;
        return true;
    }
    else // This means that there is a line intersection but not a ray intersection.
        return false;
}

int main(int argc, char const *argv[])
{
    /* 
        some driver code I'm too tired I'll do it tomorrow
    */
    return 0;
}
