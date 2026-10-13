#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 itemSize;
    float fillRatio;
    float strokeWidth;
    float useSineWave;
    vec4 accentColor;
    vec4 params;
    vec4 trackColor;
};

const float PI = 3.141592653589793;

float waveOffset(float theta, float amp, float cycles) {
    return amp * sin(theta * cycles);
}

float ringDistance(vec2 d, float dist, float theta, float radius, float amp, float cycles, float strokeW) {
    float f = dist - radius;
    float slope = 0.0;
    if (useSineWave > 0.5) {
        f -= waveOffset(theta, amp, cycles);
        slope = amp * cycles * cos(theta * cycles) / max(dist, 1.0);
    }
    return abs(f) / sqrt(1.0 + slope * slope) - strokeW * 0.5;
}

void main() {
    vec2 p = qt_TexCoord0 * itemSize;
    vec2 center = itemSize * 0.5;
    vec2 d = p - center;
    float dist = length(d);

    float outer = min(center.x, center.y) - 1.0;
    if (outer <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float strokeW = min(strokeWidth > 0.0 ? strokeWidth : 2.2, outer * 0.6);
    float amp = (useSineWave > 0.5) ? (params.x > 0.0 ? params.x : strokeW * 0.35) : 0.0;
    amp = min(amp, strokeW * 0.5);
    float radius = params.y > 0.0 ? params.y : outer - amp - strokeW * 0.5;
    if (radius <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float cycles = params.z > 0.0 ? params.z : max(3.0, floor(2.0 * PI * radius / (strokeW * 3.6) + 0.5));
    if (amp > 0.0) {
        amp = min(amp, 0.5 * radius / cycles);
    }

    float theta = atan(d.y, d.x) + PI * 0.5;
    if (theta < 0.0) theta += 2.0 * PI;

    float dTrack = ringDistance(d, dist, theta, radius, amp, cycles, strokeW);
    float trackAlpha = clamp(0.5 - dTrack, 0.0, 1.0) * trackColor.a;

    float fill = clamp(fillRatio, 0.0, 1.0);
    float sweep = 2.0 * PI * fill;

    float dProg = 1e6;
    if (fill > 0.001) {
        if (fill >= 0.999 || theta <= sweep) {
            dProg = dTrack;
        }
        if (fill < 0.999) {
            float endA = -PI * 0.5 + sweep;
            float rEnd = radius + (useSineWave > 0.5 ? waveOffset(sweep, amp, cycles) : 0.0);
            vec2 startCap = center + vec2(0.0, -radius);
            vec2 endCap = center + rEnd * vec2(cos(endA), sin(endA));
            dProg = min(dProg, min(length(p - startCap), length(p - endCap)) - strokeW * 0.5);
        }
    }

    float progAlpha = clamp(0.5 - dProg, 0.0, 1.0);
    float a = progAlpha + trackAlpha * (1.0 - progAlpha);
    vec3 rgb = accentColor.rgb * progAlpha + trackColor.rgb * trackAlpha * (1.0 - progAlpha);
    fragColor = vec4(rgb * qt_Opacity, a * qt_Opacity);
}
