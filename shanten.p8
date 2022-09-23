pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

tiles={[0]="1m","2m","3m","4m","5m","6m","7m","8m","9m",
"1s","2s","3s","4s","5s","6s","7s","8s","9s",
"1p","2p","3p","4p","5p","6p","7p","8p","9p",
"ew","sw","ww","nw","rd","gd","wd"}
tilespr={}
for k,v in pairs(tiles) do
  tilespr[v]=k
end
hands = {
  [0]={"1m","9m","1p","9p","1s","9s","ew","sw","ww","nw","rd","gd","wd","7m"},
  {"1m","2m","3m","4m","5m","6m","9m","1m","2m","3m","4m","5m","6m","7s"},
}
shantens = {}
function _init()
  printh("NEW RUN", "shantenlog.txt", true)
  printh(stat(1) .. "\n\n", "shantenlog.txt")
  for j=0,4 do
    if hands[j] == nil then
      hands[j] = {}
      for i=0,13 do
        local k = flr(rnd(#tiles))
        add(hands[j],tiles[k])
      end
    end
    sortHand(hands[j])
  end

  for i, hand in pairs(hands) do
    shantens[i] = "km:" .. shanten_kokushi(hand) .. "\t7p:" .. shanten_chiitoi(hand) .. "\tst:" .. shanten_normal(hand)
  end
  printh("total calc time " .. time() .. "s", "shantenlog.txt")
  printh("total copy time " .. copyT .. "s", "shantenlog.txt")
  printh(stat(1) .. "\n\n", "shantenlog.txt")
end
function _update()
end
function _draw()
  cls()
  local lines = 2
  for i,hand in pairs(hands) do
    for j,tile in pairs(hand) do
      -- print(tile,(j-1)*8,i*2*8,7)
      spr(tilespr[tile],(j-1)*8,i*lines*8)
    end
    print(shantens[i], 0, 8 * (i * lines + 1) + 1)
    -- print("chiitoitsu: " .. shanten_chiitoi(hand), 0, 8 * (i * lines + 2))
  end
end

function convertToLookupTable(hand)
  local lookup = {}
  for i=0,#tiles do
    lookup[i] = 0
  end
  for tile in all(hand) do
    lookup[tilespr[tile]] += 1
  end
  return lookup
end

function lookupToStr(lookup)
  local str = ""
  for i=0,#tiles do
    str = str .. lookup[i]
  end
  return str
end

kokushi_idx = {0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33}
function shanten_kokushi(hand)
  local pairs = 0
  local singles = 0
  local lookup = convertToLookupTable(hand)
  for idx in all(kokushi_idx) do
    if lookup[idx] >= 2 then
      pairs += 1
    elseif lookup[idx] == 1 then
      singles += 1
    end
  end

  return 14  - singles - (pairs > 0 and 1 or 0)
end

function shanten_chiitoi(hand)
  local pairs = 0
  local lookup = convertToLookupTable(hand)
  for i=0,#tiles do
    if lookup[i] >= 2 then
      pairs += 1
    end
  end
  return 7 - pairs
end

t = time()
function shanten_normal(hand)
  local lookup = convertToLookupTable(hand)
  t = time()
  printh("Hand:  " .. lookupToStr(lookup), "shantenlog.txt")
  local minShanten = 8
  local minShantenStateKey 

  -- look at all possible combinations of pairs (atama), melds (mentsu), and potential melds (taatsu)
  -- without recursion
  -- we'll push every state into a stack, in a whiel loop
  -- each state is a tuple {handLookup, atama, mentsu, taatsu}
  local processedStates = {}
  local states = {}
  local currentStateKey = lookupToStr(lookup)
  states[currentStateKey] = { lookup, 0, 0, 0 }
  local atamaTSum = 0
  local mentsuTSum = 0
  local taatsuTSum = 0
  while (table.len(states) > 0) do
    local currentState = states[currentStateKey]
    
    -- for each possible branch, make a copy of lookup and see if we removed tiles
    -- atama
    local atamaT = time()
    if currentState[2] == 0 then -- find a single pair
      for i=0, #tiles do
        local removedPair = removePair(table.copy(currentState[1]), i)
        if removedPair then
          local removedKey = lookupToStr(removedPair)
          if states[removedKey] == nil and processedStates[removedKey] == nil  then
            -- printh("pr: " .. removedKey, "shantenlog.txt")
            states[removedKey] = { removedPair, currentState[2] + 1, currentState[3], currentState[4] }
          end
        end
      end
    end
    atamaTSum += time() - atamaT

    -- mentsus
    local mentsuT = time()
    for i=0, #tiles do
      local removedTQ = removeMentsuTripletQuad(table.copy(currentState[1]), i)
      if removedTQ then
        local removedKey = lookupToStr(removedTQ)
        if states[removedKey] == nil and processedStates[removedKey] == nil  then
          -- printh("tq: " .. removedKey, "shantenlog.txt")
          states[removedKey] = { removedTQ, currentState[2], currentState[3] + 1, currentState[4] }
        end
      end
      local removedSequence = removeMentsuSequence(table.copy(currentState[1]), i)
      if removedSequence then
        local removedKey = lookupToStr(removedSequence)
        if states[removedKey] == nil and processedStates[removedKey] == nil  then
          -- printh("sq: " .. removedKey, "shantenlog.txt")
          states[removedKey] = { removedSequence, currentState[2], currentState[3] + 1, currentState[4] }
        end
      end
    end
    mentsuTSum += time() - mentsuT

    -- taatsus
    local taatsuT = time()
    for i=0, #tiles do
      local removedToitsu = removeTaatsuToitsu(table.copy(currentState[1]), i)
      if removedToitsu then
        local removedKey = lookupToStr(removedToitsu)
        if states[removedKey] == nil and processedStates[removedKey] == nil  then
          -- printh("tt: " .. removedKey, "shantenlog.txt")
          states[removedKey] = { removedToitsu, currentState[2], currentState[3], currentState[4] + 1 }
        end
      end
      local removedSequence = removeTaatsuSeq(table.copy(currentState[1]), i)
      if removedSequence then
        local removedKey = lookupToStr(removedSequence)
        if states[removedKey] == nil and processedStates[removedKey] == nil  then
          -- printh("ts: " .. removedKey, "shantenlog.txt")
          states[removedKey] = { removedSequence, currentState[2], currentState[3], currentState[4] + 1 }
        end
      end
    end
    taatsuTSum += time() - taatsuT

    -- remove state from stack since we are out of tiles to remove
    processedStates[currentStateKey] = table.copy(currentState)
    states[currentStateKey] = nil

    -- compare shanten
    local currentShanten = calculateShanten(currentState[3], currentState[4], currentState[2])
    if (currentShanten < minShanten) then
      -- printh("currentShanten " .. currentShanten .. " < " .. minShanten .. " minShanten", "shantenlog.txt")
      -- printh(""  .. currentStateKey .. "\n" .. 
      -- currentState[2] .. " atama\t" ..
      -- currentState[3] .. " mentsu\t" .. 
      -- currentState[4] .. " taatsu\t", "shantenlog.txt")
      minShanten = currentShanten
      minShantenStateKey = currentStateKey
    end

    -- set the next state as the new first state
    for k, v in pairs(states) do
      currentStateKey = k
      break
    end
    -- printh("looped, " .. table.len(states) .. " states remaining", "shantenlog.txt")
  end
  -- printh("minShanten"  .. minShantenStateKey, "shantenlog.txt")
  if minShantenStateKey != nil then
    printh("Shanten: " .. minShanten .. "\t" ..
      -- ""  .. lookupToStr(processedStates[minShantenStateKey][1]) .. "\n" .. 
      processedStates[minShantenStateKey][2] .. " atama\t" ..
      processedStates[minShantenStateKey][3] .. " mentsu\t" .. 
      processedStates[minShantenStateKey][4] .. " taatsu\t", "shantenlog.txt")
  end
  printh("calculation times:\tatama: " .. atamaTSum .. "s" ..
    "\t mentsu: " .. mentsuTSum .. "s" ..
    "\t taatsu: " .. taatsuTSum .. "s", "shantenlog.txt")
    printh(stat(1), "shantenlog.txt")
  printh("finished with " .. time() - t .. "s", "shantenlog.txt")
  printh("\n\n", "shantenlog.txt")
  return minShanten

  -- -- recursively do the below
  -- -- 1. remove an atama pair if any
  -- -- 2. remove all completed melds (3 or 4 tiles), if any
  -- -- 3. remove all possible protoruns/remaining pairs (2 tiles): penchan/kanchan/ryanmen/toitsu, if any
  -- local minShanten = 8

  -- -- for each pair
  -- for i=0,#tiles do
  --   if lookup[i] >= 2 then
  --     -- code mutates handLookup, so make a copy for each run
  --     local handCopy = table.copy(lookup)
  --     handCopy[i] -= 2
  --     local pair = 1
  --     local mentsu = removeMentsu(handCopy)
  --     local taatsu = removeTaatsu(handCopy)
  --     minShanten = min(minShanten, calculateShanten(mentsu, taatsu, pair))
  --   end
  -- end
  -- -- calculate shanten for no pairs
  -- local handCopy = table.copy(lookup)
  -- local pair = 0
  -- local mentsu = removeMentsu(handCopy)
  -- local taatsu = removeTaatsu(handCopy)
  -- minShanten = min(minShanten, calculateShanten(mentsu, taatsu, pair))

  -- return minShanten
end

function calculateShanten(mentsu, taatsu, atama)
  return 8 - (mentsu * 2) - taatsu - atama
end

function removePair(handLookup, start)
  for i=start,#tiles do
    if handLookup[i] >= 2 then
      handLookup[i] -= 2
      return handLookup
    end
  end
  return nil
end

function removeMentsuTripletQuad(handLookup, start)
  for i=start,#tiles do
    if isQuad(handLookup, i) then
      handLookup[i] -= 4
      return handLookup
    end
    if isTriplet(handLookup, i) then
      handLookup[i] -= 3
      return handLookup
    end
  end
  return nil
end

function removeMentsuSequence(handLookup, start)
  for i=start,#tiles do
    if isSuite(i) and isSequence(handLookup, i) then
      handLookup[i] -= 1
      handLookup[i+1] -= 1
      handLookup[i+2] -= 1
      return handLookup
    end
  end
  return nil
end

function removeTaatsuToitsu(handLookup, start)
  for i=start,#tiles do
    if isPair(handLookup, i) then
      handLookup[i] -= 2
      return handLookup
    end
  end
end

function removeTaatsuSeq(handLookup, start)
  for i=start,#tiles do
    if isSuite(i) then
      if isPotentialRyanmenPenchan(handLookup, i) then
        handLookup[i] -= 1
        handLookup[i+1] -= 1
        return handLookup
      end
      if isPotentialKanchan(handLookup, i) then
        handLookup[i] -= 1
        handLookup[i+2] -= 1
        return handLookup
      end
    end
  end
end

function isSuite(i)
  return i < 27
end

function isPair(handLookup, i)
  return handLookup[i] >= 2
end

function isTriplet(handLookup, i)
  return handLookup[i] >= 3
end

function isQuad(handLookup, i)
  return handLookup[i] == 4
end

function isSequence(handLookup, i)
  return i % 9 < 7 and handLookup[i] > 0 and handLookup[i+1] > 0 and handLookup[i+2] > 0
end


function isPotentialRyanmenPenchan(handLookup, i)
  return (i % 9 < 8 and handLookup[i] > 0 and handLookup[i+1] > 0)
end

function isPotentialKanchan(handLookup, i)
  return (i % 9 < 7 and handLookup[i] > 0 and handLookup[i+2] > 0)
end

function sortHand(a)
  for i=1,#a do
    local j = i
    while j > 1 and (tilespr[a[j-1]] > tilespr[a[j]]) do
        a[j],a[j-1] = a[j-1],a[j]
    j = j - 1
    end
  end
end
-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
table = {}
copyT = time()
function table.copy(t)
  local _copyT = time()
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  copyT += time() - _copyT
  return setmetatable(u, getmetatable(t))
end
function table.str(t)
  local s = "{"
  for k,v in pairs(t) do
    s = s .. "" .. k .. ": " .. v .. ","
  end
  return s .. "}"
end
function table.len(t)
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
  end
  return count
end
__gfx__
00777770007777700077777000777770007f55500077f77000777770007777700077777000777770007777700077777000777770007777700077777000777770
0777777f0777777f0755555f0755555f0f55d77f0777577f0775775f0777577f0775777f077b337f0777377f0777377f0737773f0737773f0737373f0777877f
07ffffff0775557f0775557f0755755f07f5557f0755555f07f5557f0777f57f0755557f0733333f0777377f0777377f0737773f0737773f0737373f0777877f
0755555f07ffffff077fff7f075f7f5f07f5757f0775757f0f55777f07f5757f07f5757f0773337f0777b77f0777377f07b777bf07b787bf07b7b7bf0737373f
0777776f0755555f0755555f0755555f0755555f0f577f5f0775555f0f57775f0757755f0778777f0777377f0737773f0737773f0737873f0737373f07b7b7bf
0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f0777777f0766666f0777377f0737773f0737773f0737773f0737373f0737373f
0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0722888f0769696f0777377f0737773f0737773f0737773f0737373f0737373f
00777770007777700077777000777770007777700077777000777770007777700077777000797970007777700077777000777770007777700077777000777770
007777700077777000777770007777700077777000777770007777700077777000f7777000777770007777700077f77000775770007777700077777000777770
0737773f07bf8f3f077ff77f0777f77f0775777f077f7f7f077f7f7f0775757f0757f77f07f5757f0757575f0775557f0775557f0755555f0775757f077f877f
0737373f07bf8f3f07f5557f077f577f0777777f0775757f0775757f077f7f7f077757ff0777777f0777777f077f5f7f077f5f7f0775757f07f5757f0788888f
0733733f0777777f0f58885f0777777f0777877f0777777f0777777f0777777f0777775f07f5757f0787878f0755555f0755555f0755555f0f55755f078f8f8f
07b777bf07bf8f3f0f58885f0777f77f0777777f077f7f7f0777877f0778787f0778787f07f5757f0777777f0755555f075d5d5f0755755f07f5757f0788888f
0733733f0777777f07f5557f077f577f0777757f0775757f0777777f0777777f0777777f0777777f0757575f0775557f07555f5f075f7f5f07f575ff077f877f
0737373f07bf8f3f077ff77f0777777f07777f7f0777777f0775757f0778787f0778787f07f5757f07f7f7ff0757575f0757555f07d555df0f57755f077f877f
00777770007777700077777000777770007777700077777000777770007777700077777000777770007777700077d770007777700077777000777770007777f0
00777770007777700044444444444444444444004233333333333333333333244233333333333333333333240077777000999990099900000000000000000000
0373373f0777777f0a22222222222222222222a04233333333333333333333244233333333333333333333240777777f09999994999940000000000000000000
0737f37f0777777f42553333333333333333552442333333333333333333332442333333333333333333332407ffffff09999994999940000000000000000000
0333333f0777777f4253333333333333333335244233333333333333333333244233333333333333333333240755555f09999994999940000000000000000000
0733337f0777777f4233333333333333333333244233333333333333333333244253333333333333333335240777776f09999994999940004999999404999994
07733f7f0777777f4233333333333333333333244233333333333333333333244255333333333333333355240777777f099999947444f000f777777f0f77777f
073f333f0777777f4233333333333333333333244233333333333333333333240a22222222222222222222a00722888f09999994077f0000f777777f0f77777f
007777f000777770423333333333333333333324423333333333333333333324004444444444444444444400007777700044444000000000f777777f0f77777f