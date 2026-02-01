shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE:hint_screen_texture,filter_linear_mipmap;

uniform bool overlay=false;

uniform float scanlines_opacity:hint_range(0.0, 1.0)=0.4;//扫描线不透明度
uniform float scanlines_width:hint_range(0.0, 0.5)=0.25;//扫描线宽度
uniform float grille_opacity:hint_range(0.0, 1.0)=0.3;//栅格不透明度
uniform vec2 resolution=vec2(640.0,480.0);//设置纹理将被划分的行数和列数，扫描线和格栅将根据这些值生成

uniform bool pixelate=true;

uniform bool roll=true;
uniform float roll_speed = 8.0;//正值向下，负值向上
uniform float roll_size:hint_range(0.0, 100.0)=15.0;
uniform float roll_variation:hint_range(0.1, 5.0)=1.8;//需要尝试不同值测试效果
uniform float distort_intensity:hint_range(0.0, 0.2)=0.05;//滚动效应产生的扭曲

uniform float noise_opacity:hint_range(0.0, 1.0)=0.4;
uniform float noise_speed = 5.0;//噪声纹理的运动速度
uniform float static_noise_intensity:hint_range(0.0, 1.0)=0.06;

uniform float aberration:hint_range(-1.0,1.0)=0.03;//色差，每个颜色通道上的失真。
uniform float brightness=1.4;//在添加扫描线间隙和格栅时，图像可能会变得非常暗。亮度会尝试对此进行补偿。
uniform bool discolor=true;//褪色效果，模拟VHS

uniform float warp_amount:hint_range(0.0,5.0)=1.0;// 扭曲纹理边缘，模拟 CRT 显示器的弯曲玻璃效果。
uniform bool clip_warp=false;
uniform float vignette_intensity = 0.4; //晕映强度，延伸到中间的程度
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

vec2 random(vec2 uv){
	uv=vec2(
		dot(uv,vec2(127.1,311.7)),
		dot(uv,vec2(269.5,183.3))
	);
	return -1.0+2.0*fract(sin(uv)* 43758.5453123);
}
float noise(vec2 uv){
	vec2 uv_index=floor(uv);
	vec2 uv_fract=fract(uv);
	vec2 blur=smoothstep(0.0,1.0,uv_fract);
	
	return mix(
		mix(
			dot(random(uv_index+vec2(0.0,0.0)),uv_fract-vec2(0.0,0.0)),
			dot(random(uv_index+vec2(1.0,0.0)),uv_fract-vec2(1.0,0.0)),blur.x
		),
		mix(
			dot(random(uv_index+vec2(0.0,1.0)),uv_fract-vec2(0.0,1.0)),
			dot(random(uv_index+vec2(1.0,1.0)),uv_fract-vec2(1.0,1.0)),blur.x
		),blur.y
	)*0.5+0.5;
}
vec2 warp(vec2 uv){
	vec2 delta =uv-0.5;
	float delta2 =dot(delta.xy,delta.xy);
	float delta4=delta2*delta2;
	float delta_offset=delta4*warp_amount;
	return uv+delta*delta_offset;
}
float border(vec2 uv){
	float radius=min(warp_amount,0.08);
	radius=max(min(min(abs(radius*2.0),abs(1.0)),abs(1.0)),1e-5);
	vec2 abs_uv=abs(uv*2.0-1.0)-vec2(1.0,1.0)+radius;
	float dist=length(max(vec2(0.0),abs_uv))/radius;
	float square=smoothstep(0.96,1.0,dist);
	return clamp(1.0-square,0.0,1.0);
}
float vignette(vec2 uv){
	uv*=1.0-uv.xy;
	float vignette=uv.x*uv.y*15.0;
	return pow(vignette,vignette_intensity*vignette_opacity);
}

void fragment() {
	vec2 uv=overlay?warp(SCREEN_UV):warp(UV);//扭曲 uv
	vec2 text_uv=uv;
	vec2 roll_uv=vec2(0.0);
	float time=roll?TIME:0.0;
	
	//分辨率，进行像素化处理
	if(pixelate)text_uv=ceil(uv*resolution)/resolution;
	
	
	//创建滚动效果。稍后需要使用 roll_line 来制造噪声效果。
	//当roll为true或noise_opacity>0时
	float roll_line=0.0;
	if(roll||noise_opacity>0.0){
		//创建纹理将被扭曲的区域。
		roll_line=smoothstep(0.3,0.9,sin(uv.y*roll_size-time*roll_speed));
		//创建更多不同尺寸的线条并应用到第一组线条上。来产生一些变化。
		roll_line*=roll_line*smoothstep(0.3,0.9,sin(uv.y*roll_size*roll_variation-time*roll_speed*roll_variation));
		//在滚动线条所在的位置扭曲UV
		roll_uv=vec2(roll_line*distort_intensity*(1.-UV.x),0.0);
	}
	
	vec4 text;
	if(roll){
		//如果 roll 为 true，则使用 roll_uv 扭曲纹理。纹理被拆分为 RGB 以产生一些色差
		//根据色差参数将色差应用于红色和绿色通道，并在 roll 扭曲中稍微增强它
		text.r=texture(SCREEN_TEXTURE,text_uv+roll_uv*0.8+vec2(aberration,0.0)*0.1).r;
		text.g=texture(SCREEN_TEXTURE,text_uv+roll_uv*1.2-vec2(aberration,0.0)*0.1).g;
		text.b=texture(SCREEN_TEXTURE,text_uv+roll_uv).b;
		text.a = 1.0;
	}
	else{
		//如果 roll 为 false，则只应用色差而不产生任何扭曲。
		text.r=texture(SCREEN_TEXTURE,text_uv+vec2(aberration,0.0)*0.1).r;
		text.g=texture(SCREEN_TEXTURE,text_uv-vec2(aberration,0.0)*0.1).g;
		text.b=texture(SCREEN_TEXTURE,text_uv).b;
		text.a = 1.0;
	}
	
	float r=text.r;
	float g=text.g;
	float b=text.b;
	
	uv=warp(UV);
	
	//CRT 显示器没有像素，而是由红、绿、蓝点或线组成的网格。将纹理的颜色通道分离
	//并将其分成三条错位的线，将红色、绿色和蓝色显示在彼此旁边，中间留有一条小黑缝。
	if(grille_opacity>0.0){
		float g_r=smoothstep(0.85,0.95,abs(sin(uv.x*(resolution.x*PI))));
		r=mix(r,r*g_r,grille_opacity);
		
		float g_g=smoothstep(0.85,0.95,abs(sin(1.05+uv.x*(resolution.x*PI))));
		g=mix(g,g*g_g,grille_opacity);
		
		float g_b=smoothstep(0.85,0.95,abs(sin(2.1+uv.x*(resolution.x*PI))));
		b=mix(b,b*g_b,grille_opacity);
	}
	//将格栅应用到纹理的颜色通道并应用亮度
	//由于格栅和扫描线会使图像非常暗，可以通过增加亮度来进行补偿。
	text.r=clamp(r*brightness,0.0,1.0);
	text.g=clamp(g*brightness,0.0,1.0);
	text.b=clamp(b*brightness,0.0,1.0);
	
	//扫描线是组成 CRT 显示器图像的水平线
	//实现：设置每条线之间的黑色间隙
	float scanlines=0.5;
	if(scanlines_opacity>0.0){
		//使用sin创建线条并应用到纹理上。smoothstep 来设置线条的大小。
		scanlines=smoothstep(scanlines_width,scanlines_width+0.5,abs(sin(uv.y*(resolution.y*PI))));
		text.rgb=mix(text.rgb,text.rgb*vec3(scanlines),scanlines_opacity);
	}
	
	//带状噪声
	if(noise_opacity>0.0){
		float noise=smoothstep(0.4,0.5,noise(uv*vec2(2.0,200.0)+vec2(10.0,TIME*noise_speed)));
		
		roll_line*=noise*scanlines*clamp(
			random(ceil(uv*resolution)/resolution+vec2(TIME*0.8,0.0)).x+0.8,0.0,1.0
			);
		
		text.rgb=clamp(mix(text.rgb,text.rgb+roll_line,noise_opacity),vec3(0.0),vec3(1.0));
	}
	
	//静态噪声(雪花)
	if(static_noise_intensity>0.0)
		text.rgb+=clamp(random((ceil(uv*resolution)/resolution)+fract(TIME)).x,0.0,1.0)*static_noise_intensity;
	
	//黑色边框+晕映
	//text.rgb *= border(uv);
	text.rgb*=vignette(uv);
	//if (clip_warp)text.a=border(uv);
	
	//应用褪色效果以获得 VHS 效果（降低饱和度并提高对比度）
	float saturation=0.5;
	float contrast=1.2;
	if(discolor){
		vec3 greyscale=vec3(text.r + text.g + text.b) / 3.;
		text.rgb=mix(text.rgb,greyscale,saturation);
		
		float midpoint=pow(0.5,2.2);
		text.rgb=(text.rgb-vec3(midpoint))*contrast+midpoint;
	}
	
	COLOR=text;
}
