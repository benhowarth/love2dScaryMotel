--import libraries
Inspect = require "lib.inspect"
Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Camera = require "lib.hump.camera"
vector = require "lib.hump.vector"

--setup window and game world size
window={}
--window.w=800
--window.h=650
window.w=0
window.h=0
game={}
game.w=4000
game.h=650
love.window.setTitle("Motel Management Simulator '98")
love.window.setMode( window.w, window.h)
window.w,window.h=love.window.getMode()
canvas = love.graphics.newCanvas(window.w, window.h)
love.window.setFullscreen(true)

love.window.setIcon(love.image.newImageData(("res/icon.png")))

love.graphics.setBackgroundColor(0,0,0)


--setup shaders
pixelShader = love.graphics.newShader [[
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          float dx=4*(1./7000);
          float dy=4*(1./7000);
          vec2 coords=vec2(dx*floor(texture_coords.x/dx),dy*floor(texture_coords.y/dx));
          vec4 pixelColor=Texel(texture,coords);
          return pixelColor*color;
      }
  ]]
vingetteShader = love.graphics.newShader [[
      extern number x;
      extern number y;
      extern number w;
      extern number h;
      extern bool light_on;
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          vec2 st=vec2(pixel_coords.x/w,pixel_coords.y/h);
          vec2 bulbCentre=vec2(x/w,y/h);
          float dist=distance(bulbCentre,st);

          float dx=4*(1./7000);
          float dy=4*(1./7000);
          vec2 coords=vec2(dx*floor(texture_coords.x/dx),dy*floor(texture_coords.y/dx));
          vec4 pixelColor=Texel(texture,coords);



          pixelColor.r=pixelColor.r;
          pixelColor.g=pixelColor.g;
          pixelColor.b=pixelColor.b;
          if(light_on==true){
            color.rgb=color.rgb-(smoothstep(0.01,0.03,dist)*0.2);
            color.rgb=color.rgb-(smoothstep(0.09,0.11,dist)*0.1);
            color.rgb=color.rgb-(smoothstep(0.3,1.1,dist));
          }else{
            color.rgb=color.rgb-(smoothstep(0.3,1.1,dist));
            color.rgb*=0.2;
          }
          return pixelColor*color;
      }
  ]]
flashlightShader = love.graphics.newShader [[
      extern number x;
      extern number y;
      extern number w;
      extern number h;
      extern number rad;
      extern number bleed;
      extern number strength;
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          vec2 st=vec2(pixel_coords.x/w,pixel_coords.y/h);
          vec2 bulbCentre=vec2(x/w,y/h);
          float dist=distance(bulbCentre,st);
          float rad=rad/w;

          float dx=4*(1./7000);
          float dy=4*(1./7000);
          vec2 coords=vec2(dx*floor(texture_coords.x/dx),dy*floor(texture_coords.y/dx));
          vec4 pixelColor=Texel(texture,coords);



          pixelColor.r=pixelColor.r;
          pixelColor.g=pixelColor.g;
          pixelColor.b=pixelColor.b;
          color.r=color.r+(1.0/smoothstep(rad-bleed,rad+bleed,dist))*strength;
          color.g=color.g+(1.0/smoothstep(rad-bleed,rad+bleed,dist))*strength;
          color.b=color.b+(1.0/smoothstep(rad-bleed,rad+bleed,dist))*strength;
          return pixelColor*color;
      }
  ]]
experimentShader = love.graphics.newShader [[
      extern number t;
      extern number wooz;
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          vec4 pixelColor=Texel(texture,texture_coords+(t+wooz/100000));
          if(wooz==1)
          {
            vec2 coords=vec2(0,0);
            if(texture_coords.x-(2*floor(texture_coords.x/2))==0)
            {
              coords=vec2(texture_coords.x+(sin(t*3.)*cos(texture_coords.y))*.01,texture_coords.y+(cos(t*3.))*sin(texture_coords.y)*.01);
            }else{
              coords=vec2(texture_coords.x+(cos(t*6.)*sin(texture_coords.y))*.05,texture_coords.y+(cos(t*2.))*sin(texture_coords.y)*.08);
            }
            vec4 pixelColor=Texel(texture,coords);
          }
          return pixelColor*color;
      }
  ]]

time=0
--text="DEBUG TEXT"

--setup images
imgs={}

for i,img in ipairs(imgs) do
  img:setFilter('nearest', 'nearest')
end;
