#version 330
in vec2 inPosition;
out vec3 vertColor;// pro osvětlení per Vertex
out vec2 texCoord;
out vec3 worldPos; //pozice bodu na povrchu telesa ve scene
out vec3 worldNormal; //normala ve scene

out float intensity;

uniform mat4 mat;
uniform int surfaceModel;
uniform int lightMode;
uniform vec3 lightPos;

const float PI = 3.14159265359;

// Převody soustav
// r - poloměr, azimut - phi, zenit - theta
vec3 spherialToCartesian(float r, float phi, float theta) {
return vec3(
        r * sin(phi) * cos(theta),
        r * sin(phi) * sin(theta),
        r * cos(phi)
    );
}

// r - poloměr, phi - azimut, výška - z
vec3 cylindricToCartesian(float r, float theta, float z){
return vec3(
        r * cos(theta),
        r * sin(theta),
        z
    );
}

//Modely
// koule
vec3 cartesianModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    return vec3(
        sin(t) * cos(s),
        sin(t) * sin(s),
        cos(t)
    );
}
// trychtýř
vec3 cartesianModel2(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    return vec3(
        t*cos(s),
        t*sin(s),
        t
    );
}
// trubka - vlastní
vec3 cartesianModel3(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    return vec3(
        cos(s),
        cos(t)*2,
        sin(s)
    );
}


// sloní hlava
vec3 spherialModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    float r = 3 + cos(4*s);
    float azimut = s; // phi
    float zenit = t;  // theta

    return spherialToCartesian(r, azimut, zenit);
}
// Koule
vec3 spherialModel2(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    float r = 1;
    float azimut = t; // phi
    float zenit = s;  // theta

    return spherialToCartesian(r, azimut, zenit);
}
// Kobliha - vlastní
vec3 spherialModel3(vec2 param){
    float s = param.x * PI;
    float t = param.y * PI;

    float r = cos(t) * sin(t);
    float azimut = t; // phi
    float zenit = s;  // theta

    return spherialToCartesian(r, azimut, zenit);
}

// sombrero
vec3 cylindricModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI * 2;

    float r = t;
    float theta = s;
    float z = 2 * sin(t);

    return cylindricToCartesian(r, theta, z);
}
// trubka - vertikální - oliva
vec3 cylindricModel2(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI * 2;

    float r = 1;
    float theta = s;
    float z = t;

    return cylindricToCartesian(r, theta, z);
}
// mušle - vlastní
vec3 cylindricModel3(vec2 param){
    float s = param.x * PI;
    float t = param.y * PI;

    float r = t;
    float theta = log(s);
    float z = sin(t);

    return cylindricToCartesian(r, theta, z);
}

vec3 surface(vec2 param) {
    vec3 result;
    switch(surfaceModel){
        case 0:
            result.x = param.y;
            result.y = param.x;
            result.z = 0;
            break;
        case 1:
            result = cartesianModel(param);
            break;
        case 2:
            result = cartesianModel2(param);
            break;
        case 3:
            result = cartesianModel3(param);
            break;
        case 4:
            result = spherialModel(param);
            break;
        case 5:
            result = spherialModel2(param);
            break;
        case 6:
            result = spherialModel3(param);
            break;
        case 7:
            result = cylindricModel(param);
            break;
        case 8:
            result = cylindricModel2(param);
            break;
        case 9:
            result = cylindricModel3(param);
            break;
    }

    return result;
}

vec3 surfaceNormal(vec2 param) {
//    vec3 tx = vec3(0,1,0);//parcialni derivace podle param.x;
//    vec3 ty = vec3(1,0,0);//parcialni derivace podle param.y;
    float delta = 1e-5;
    vec3 tx = (surface(param + vec2(delta, 0))
                - surface(param - vec2(delta, 0))) / (2 * delta);
    vec3 ty = (surface(param + vec2(0, delta))
                - surface(param - vec2(0, delta))) / (2 * delta);
    return cross(ty, tx);
}

void main() {
    bool perVertex = lightMode==0;

    vec3 position = surface(inPosition);
    vec3 normal = surfaceNormal(inPosition);
	gl_Position = mat * vec4(position, 1.0);

	worldPos = position;
	worldNormal = normal;
	texCoord = inPosition;

	if(perVertex){
        vec3 lightVec = normalize(lightPos - worldPos);
        intensity = dot(lightVec, normal);
        vertColor = vec3(normal.xyz);
	}
}