#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// ── Noise primitives ─────────────────────────────────────────────────────────

static float hash2(float2 p) {
    p = fract(p * float2(127.1, 311.7));
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

static float vnoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash2(i),                hash2(i + float2(1, 0)), u.x),
        mix(hash2(i + float2(0, 1)), hash2(i + float2(1, 1)), u.x),
        u.y
    );
}

static float fbm(float2 p, int octaves) {
    float v = 0.0, a = 0.5;
    float2x2 rot = float2x2(float2(0.8, 0.6), float2(-0.6, 0.8));
    for (int i = 0; i < octaves; i++) {
        v += a * vnoise(p);
        p = rot * p * 2.1;
        a *= 0.5;
    }
    return v;
}

static float2 rotate2(float2 v, float a) {
    float c = cos(a), s = sin(a);
    return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

// ── Xuan paper (宣紙) ─────────────────────────────────────────────────────────
// Anisotropic fiber noise at multiple orientations + micro grain + cloud.

static float fiberLayer(float2 uv, float angle, float scale) {
    float2 r = rotate2(uv * scale, angle);
    float2 stretched = float2(r.x * 1.0, r.y * 0.07);
    float curl = vnoise(stretched * float2(1.0, 0.12)) * 0.6;
    stretched.x += curl;
    return vnoise(stretched);
}

[[ stitchable ]] half4 marble(float2 position, half4 color, float2 size, float isDark) {
    float2 uv = position / size;

    float f1 = fiberLayer(uv, 0.05f, 7.0);
    float f2 = fiberLayer(uv, 1.62f, 6.5);
    float f3 = fiberLayer(uv, 0.84f, 8.0);
    float fibers = f1 * 0.45 + f2 * 0.32 + f3 * 0.23;

    float microA = fbm(uv * 24.0 + float2(5.3, 2.1), 3);
    float microB = vnoise(uv * 55.0 + float2(9.7, 4.4));
    float micro  = microA * 0.6 + microB * 0.4;

    float cloud = fbm(uv * 2.2 + float2(1.9, 7.3), 5);

    float t = cloud * 0.38 + fibers * 0.42 + micro * 0.20;

    half3 lightHi = half3(0.982, 0.970, 0.950);
    half3 lightLo = half3(0.858, 0.842, 0.815);
    half3 darkHi  = half3(0.512, 0.502, 0.488);
    half3 darkLo  = half3(0.398, 0.390, 0.376);

    half3 hi = mix(lightHi, darkHi, half(isDark));
    half3 lo = mix(lightLo, darkLo, half(isDark));
    half contrast = mix(half(0.28), half(0.22), half(isDark));
    return half4(mix(hi, lo, half(t) * contrast), 1.0);
}

// ── Stone marble (大理石) ──────────────────────────────────────────────────────
// Flowing veins via domain-warped sine zero-crossings.
// Primary veins: bold diagonal sweep. Secondary: thinner crossing veins.
// Inspired by the white Carrara-style stone of the image sundial (日晷).

[[ stitchable ]] half4 stoneMarble(float2 position, half4 color, float2 size, float isDark) {
    float2 uv = position / size;

    // Two-layer domain warp for organic vein flow
    float2 q = float2(
        fbm(uv * 2.8,                       4),
        fbm(uv * 2.8 + float2(5.2,  1.3),   4)
    );
    float2 r = float2(
        fbm(uv * 2.2 + 3.2 * q + float2(1.7, 9.2), 4),
        fbm(uv * 2.2 + 3.2 * q + float2(8.3, 2.8), 4)
    );
    float2 w = uv + 0.38 * r;

    // Primary vein family — broad diagonal sweeps like the sundial stone
    float n1   = fbm(w * 2.0, 5);
    float sine1 = sin((w.x * 2.8 + w.y * 1.1) * M_PI_F + n1 * 7.5);
    // Zero-crossings of sine = vein centre; smoothstep sharpens the edge
    float pv = 1.0 - smoothstep(0.0, 0.14, abs(sine1));
    pv = pow(pv, 1.8);

    // Secondary vein family — thinner, different angle, adds branching feel
    float n2   = fbm(w * 3.0 + float2(3.1, 6.7), 4);
    float sine2 = sin((w.x * 0.9 + w.y * 3.2) * M_PI_F + n2 * 5.5);
    float sv = 1.0 - smoothstep(0.0, 0.07, abs(sine2));
    sv = pow(sv, 2.2);

    // Hairline accent veins (very thin, sparse)
    float n3   = fbm(w * 4.5 + float2(7.3, 1.9), 3);
    float sine3 = sin((w.x * 4.0 + w.y * 1.8) * M_PI_F + n3 * 4.0);
    float hv = 1.0 - smoothstep(0.0, 0.03, abs(sine3));

    // Subtle base cloud — stone is not perfectly flat
    float baseTex = fbm(uv * 6.0 + float2(2.2, 5.1), 3) * 0.06;

    float veins = pv * 0.75 + sv * 0.45 + hv * 0.25;
    float t = clamp(veins + baseTex, 0.0, 1.0);

    // Light mode: white Carrara marble base, blue-grey veins
    half3 lightBase = half3(0.978, 0.972, 0.964);   // #F9F8F6 cold white
    half3 lightVein = half3(0.520, 0.518, 0.512);   // #848380 grey vein

    // Dark mode: dark slate base, lighter quartz veins
    half3 darkBase  = half3(0.210, 0.205, 0.200);   // #353433 deep slate
    half3 darkVein  = half3(0.500, 0.492, 0.478);   // #807D7A lighter vein

    half3 base = mix(lightBase, darkBase, half(isDark));
    half3 vein = mix(lightVein, darkVein, half(isDark));

    return half4(mix(base, vein, half(t)), 1.0);
}
