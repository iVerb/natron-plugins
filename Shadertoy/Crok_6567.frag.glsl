//
//
//                          MMMMMMMMMMMMMMMMMMMMMMMMMMMM
//                        MM.                          .MM
//                       MM.  .MMMMMMMMMMMMMMMMMMMMMM.  .MM
//                      MM.  .MMMMMMMMMMMMMMMMMMMMMMMM.  .MM
//                     MM.  .MMMM        MMMMMMM    MMM.  .MM
//                    MM.  .MMM           MMMMMM     MMM.  .MM
//                   MM.  .MmM              MMMM      MMM.  .MM
//                  MM.  .MMM                 MM       MMM.  .MM
//                 MM.  .MMM                   M        MMM.  .MM
//                MM.  .MMM                              MMM.  .MM
//                 MM.  .MMM                            MMM.  .MM
//                  MM.  .MMM       M                  MMM.  .MM
//                   MM.  .MMM      MM                MMM.  .MM
//                    MM.  .MMM     MMM              MMM.  .MM
//                     MM.  .MMM    MMMM            MMM.  .MM
//                      MM.  .MMMMMMMMMMMMMMMMMMMMMMMM.  .MM
//                       MM.  .MMMMMMMMMMMMMMMMMMMMMM.  .MM
//                        MM.                          .MM
//                          MMMMMMMMMMMMMMMMMMMMMMMMMMMM
//
//
//
//
// Adaptation pour Natron par F. Fernandez
// Code original : crok_6567 Matchbox pour Autodesk Flame

// Adapted to Natron by F.Fernandez
// Original code : crok_6567 Matchbox for Autodesk Flame


// iChannel0: Source, filter=nearest, wrap=clamp
// BBox: iChannel0

uniform float saturation = 1.0; // Saturation : (saturation), min=0.0, max=100.0
uniform float pixelSize = 3.0; // Pixel size : (pixel size), min=0.01, max=1000
uniform float noise = 1.0; // Noise : (noise), min=0.0, max=10000

// Maps into DawnBringer's 4-bit (16 color) palette http://www.pixeljoint.com/forum/forum_posts.asp?TID=12795
// https://www.shadertoy.com/view/ldXSz4


float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }


float compare(vec3 a, vec3 b) {
	// Increase saturation
	a = max(vec3(0.0), a - min(a.r, min(a.g, a.b)) * 0.25 * saturation);
	b = max(vec3(0.0), b - min(b.r, min(b.g, b.b)) * 0.25 * saturation);
	a*=a*a;
	b*=b*b;
	vec3 diff = (a - b);
	return dot(diff, diff);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 c = floor(fragCoord.xy / pixelSize);
	vec2 coord = c * pixelSize;
	vec3 src = texture2D(iChannel0, coord / iResolution.xy).rgb;
	
	// Track the two best colors
	vec3 dst0 = vec3(0), dst1 = vec3(0);
	float best0 = 1e3, best1 = 1e3;
#	define TRY(R, G, B) { const vec3 tst = vec3(R, G, B); float err = compare(src, tst); if (err < best0) { best1 = best0; dst1 = dst0; best0 = err; dst0 = tst; } }

	TRY(0.078431, 0.047059, 0.109804);
    TRY(0.266667, 0.141176, 0.203922);
    TRY(0.188235, 0.203922, 0.427451);
    TRY(0.305882, 0.290196, 0.305882);
    TRY(0.521569, 0.298039, 0.188235);
    TRY(0.203922, 0.396078, 0.141176);
    TRY(0.815686, 0.274510, 0.282353);
    TRY(0.458824, 0.443137, 0.380392);
    TRY(0.349020, 0.490196, 0.807843);
    TRY(0.823529, 0.490196, 0.172549);
    TRY(0.521569, 0.584314, 0.631373);
    TRY(0.427451, 0.666667, 0.172549);
    TRY(0.823529, 0.666667, 0.600000);
    TRY(0.427451, 0.760784, 0.792157);
    TRY(0.854902, 0.831373, 0.368627);
    TRY(0.870588, 0.933333, 0.839216);
#	undef TRY	

	best0 = sqrt(best0); best1 = sqrt(best1);
	fragColor = vec4(mod(c.x + c.y, 2.0 * noise) >  (hash(c * 2.0 * noise + fract(sin(vec2(floor(1.9*noise), floor( 1.7*noise))))) * 0.75*noise) + (best1 / (best0 + best1)) ? dst1 : dst0, 1.0);
}