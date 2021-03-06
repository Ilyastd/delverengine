uniform mat4 u_projectionViewMatrix;
uniform float u_fogStart;
uniform float u_fogEnd;

uniform vec4 u_AmbientColor;
uniform vec4 u_FogColor;

uniform float u_time;
uniform float u_tex_width;
uniform float u_tex_height;
uniform int u_sprite_columns;
uniform int u_sprite_rows;

uniform vec4 u_LightColors[{{MAX_DYNAMIC_LIGHTS}}];
uniform vec3 u_LightPositions[{{MAX_DYNAMIC_LIGHTS}}];
uniform int u_UsedLights;

uniform float u_wave_offset;

attribute vec4 a_position;
attribute vec4 a_color;
attribute vec2 a_texCoord0;

varying vec2 v_texCoords;
varying vec4 v_color;

varying float v_fogFactor;
varying float v_eyeDistance;

vec4 vertexPositionInEye;

const float c_zerof = 0.0;
const float c_onef = 1.0;

float calcFogFactor(float distanceToEye);
float calcAttachment();

void main() {
  v_texCoords = a_texCoord0;

  vec4 newPos = a_position;

  float gust = sin(a_position.x + a_position.z + a_position.y + u_time) * 0.5;

  float swayMod = clamp(calcAttachment(), -1.0, 1.0);

  gl_Position = u_projectionViewMatrix * newPos;

  gl_Position.x += (gust * 0.15) * swayMod;
  gl_Position.z += (gust * 0.05) * swayMod;
  gl_Position.y += (abs(gust * gust) * -0.1) * swayMod;

  v_color = a_color + u_AmbientColor;

  for(int i=0; i < {{MAX_DYNAMIC_LIGHTS}}; i++)
  {
    if(v_color.a != 0.0 && u_LightColors[i].a != 0.0)
    {
  	  float lightDistance = length(u_LightPositions[i] - gl_Position.xyz) / u_LightColors[i].a;
      float diffuse = (1.0 / (1.0 + (lightDistance * lightDistance)));
      v_color += u_LightColors[i] * diffuse;
    }
  }

  v_color.a = 1.0;
    
  vertexPositionInEye = gl_Position;
  v_fogFactor = calcFogFactor(-vertexPositionInEye.z);
  v_eyeDistance = -vertexPositionInEye.z;
}

float calcFogFactor(float distanceToEye)
{
    float f = (u_fogEnd - -distanceToEye) / (u_fogEnd - u_fogStart);
	return clamp(f, c_zerof, c_onef);
}

float calcAttachment() {
  return a_position.y;
}