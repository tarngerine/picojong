pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
t = 0
tiles={[0]="r","g","w","e","s","w","n",
"1m","2m","3m","4m","5m","6m","7m","8m","9m",
"1s","2s","3s","4s","5s","6s","7s","8s","9s",
"1p","2p","3p","4p","5p","6p","7p","8p","9p"}
tilespr={}
for k,v in pairs(tiles) do
  tilespr[v]=k
end
wall={}
player={}
player.hand={}

function _init()
  -- printh("running", "log.txt", true)
  genWall()
  -- printh("wall generated: " .. #wall, "log.txt")
  -- for k,v in pairs(wall) do
  --   printh(k .. ": " .. v,"log.txt")
  -- end
end

function _draw()
  cls()
  map(0,0,0,0,128,64)
  print("picojong", 128 - 32, 128 - 6, 1)
  print("picojong", 128 - 31, 128 - 5, 9)

  cols=14
  for i,tile in pairs(wall) do
    spr(tilespr[tile],(i-1)%cols*8+8,flr((i-1)/cols)*12+6)
  end
  t += 1
end

function genWall()
  for j=0,3 do
    for i=0,#tiles do
      add(wall,tiles[i])
    end
  end
  --shuffle
	for i = #wall, 2, -1 do
		local j = ceil(rnd(i))
		wall[i], wall[j] = wall[j], wall[i]
	end
end
__gfx__
0077777000777770007777700077f77000775770007777700077777000777770007777700077777000777770007f55500077f770007777700077777000777770
077f877f0373373f0777777f0775557f0775557f0755555f0775757f0777777f0775557f0755555f0755555f0f55d77f0777577f0775775f0775577f0775777f
0788888f0737f37f0777777f077f5f7f077f5f7f0775757f07f5757f07ffffff07ffffff0775557f0755755f07f5557f0755555f07f5557f0777f57f0755557f
078f8f8f0333333f0777777f0755555f0755555f0755555f0f55755f0755555f0755555f077fff7f075f7f5f07f5757f0775757f0f55777f07f57f5f07f5757f
0788888f0733337f0777777f0755555f075d5d5f0755755f07f5757f0777776f0777777f0755555f0755555f0755555f0f577f5f0775555f0f57775f0757755f
077f877f07733f7f0777777f0775557f07555f5f075f7f5f07f575ff0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f
077f877f073f333f0777777f0757575f0757555f07d555df0f57755f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f
007777f0007777f0007777700077d770007777700077777000777770007777700077777000777770007777700077777000777770007777700077777000777770
00777770007777700077777000777770007777700077777000777770007777700777777f00777770007777700077777000777770007777700077777000f77770
077b337f0777377f0777377f0737773f0737773f0737373f0777877f0737773f07bf8f3f077ff77f0777f77f0775777f077f7f7f077f7f7f0775757f0757f77f
0733333f0777377f0777377f0737773f0737773f0737373f0777877f0737373f07bf8f3f07f5557f077f577f0777777f0775757f0775757f077f7f7f077757ff
0773337f0777b77f0777377f07b777bf07b787bf07b7b7bf0737373f0733733f0777777f0f58885f0777777f0777877f0777777f0777777f0777777f0777775f
0778777f0777377f0737773f0737773f0737873f0737373f07b7b7bf07b777bf07bf8f3f0f58885f0777f77f0777777f077f7f7f0777877f0778787f0778787f
0766666f0777377f0737773f0737773f0737773f0737373f0737373f0733733f0777777f07f5557f077f577f0777757f0775757f0777777f0777777f0777777f
0769696f0777377f0737773f0737773f0737773f0737373f0737373f0737373f07bf8f3f077ff77f0777777f07777f7f0777777f0775757f0778787f0778787f
00797970007777700077777000777770007777700077777000777770007777700f77777f00777770007777700077777000777770007777700077777000777770
00777770007777700044444444444444444444004233333333333333333333244233333333333333333333240000000000000000000000000000000000000000
07f5757f0757575f0a22222222222222222222a04233333333333333333333244233333333333333333333240000000000000000000000000000000000000000
0777777f0777777f4255333333333333333355244233333333333333333333244233333333333333333333240000000000000000000000000000000000000000
07f5757f0787878f4253333333333333333335244233333333333333333333244233333333333333333333240000000000000000000000000000000000000000
07f5757f0777777f4233333333333333333333244233333333333333333333244253333333333333333335240000000000000000000000000000000000000000
0777777f0757575f4233333333333333333333244233333333333333333333244255333333333333333355240000000000000000000000000000000000000000
07f5757f07f7f7ff4233333333333333333333244233333333333333333333240a22222222222222222222a00000000000000000000000000000000000000000
00777770007777704233333333333333333333244233333333333333333333240044444444444444444444000000000000000000000000000000000000000000
__map__
2223232323232323232323232323232400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262626262626262626262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2829292929292929292929292929292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000002c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
