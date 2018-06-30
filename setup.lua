--import libraries
Inspect = require "lib.inspect"
Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
Camera = require "lib.hump.camera"
vector = require "lib.hump.vector"

--setup window and game world size
window={}
window.w=800
window.h=650
canvas = love.graphics.newCanvas(window.w, window.h)
game={}
game.w=4000
game.h=650
love.window.setTitle("Motel")
love.window.setMode( window.w, window.h)
--love.window.setFullscreen(true)

love.graphics.setBackgroundColor(0,0,0)


--setup shaders
pixelShader = love.graphics.newShader [[
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {
          float dx=30*(1./7000);
          float dy=30*(1./7000);
          vec2 coords=vec2(dx*floor(texture_coords.x/dx),dy*floor(texture_coords.y/dx));
          vec4 pixelColor=Texel(texture,coords);
          return pixelColor*color;
      }
  ]]
partyShader = love.graphics.newShader [[
      extern number time;
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
      {

          vec4 pixelColor=Texel(texture,texture_coords);
          pixelColor.r=pixelColor.r*sin(time*10.);
          pixelColor.b=pixelColor.b*sin(time*8.);
          pixelColor.g=pixelColor.g*sin(time*5.);
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
