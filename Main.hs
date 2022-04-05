module Main where

import           Data.SBV
import           Data.SBV.Trans.Control

main = do
  res <- optimize Lexicographic configure
  print res

configure :: Goal
configure = do
  engineNames <- sInt32s $ getName <$> engines' -- engines' is Integer only

  let engineCost = costAmount engineNames
      thrust = thrustAmount engineNames -- round down floats
      turn = turnAmount engineNames -- round down floats

  constrain $ engineCost .<= 210 -- Kestrel + Weapons
  constrain $ engineCost .>= 0 -- can't be negative!
  constrain $ thrust .> 0
  constrain $ turn .> 0
  mapM_ (\x -> constrain $ x .>= 0) engineNames -- zero or more of each component
  mapM_ (\x -> constrain $ x .<= 10) engineNames -- I can't imagine more than ten of any component?

  -- (20*total_thrust+1060)*total_turn maps the thrust range onto the steering range for the entire set of steering/thruster (thanks opticron!)
  maximize "sum thrust and steering/36" (((thrust * 20) + 1060) * turn :: SInt32)

costAmount :: [SInt32] -> SInt32
costAmount es = sum $ zipWith (*) (getSize <$> engines') es

turnAmount :: [SInt32] -> SInt32
turnAmount es = sum $ zipWith (*) (getTurn <$> engines') es

thrustAmount :: [SInt32] -> SInt32
thrustAmount es = sum $ zipWith (*) (getThrust <$> engines') es

getName (n,_,_,_) = n
getSize (_,s,_,_) = s
getThrust (_,_,th,_) = th
getTurn (_,_,_,tu) = tu

{- many engines, with different amounts of thrust and turning
a ship has limited space
What combination of engines fits into the ship, and gives the most thrust? -}

-- values from https://github.com/endless-sky/endless-sky/blob/master/data/engines.txt
-- name, size, thrust, turning
-- this one multiplies all float values by 10 to make them integers
engines' :: [(String, SInt32, SInt32, SInt32)]
engines' = [ ("X1050", 20, 40, 1100) -- has both thrust and turning!
          -- , ("X1200", 12, 0, 1600)
          -- , ("X1700", 16, 60, 0)
          -- , ("X2200", 20, 0, 3070)
          -- , ("X2700", 27, 115, 0)
          -- , ("X3200", 35, 0, 5900)
          -- , ("X3700", 46, 221, 0)
          -- , ("X4200", 59, 0, 11320)
          -- , ("X4700", 79, 425, 0)
          -- , ("X5200", 100, 0, 21740)
          -- , ("X5700", 134, 815, 0)
          -- , ("Chipmunk Thruster", 20, 96, 0)
          -- , ("Chipmunk Steering", 15, 0, 2560)
          -- , ("Greyhound Steering", 26, 0, 4920)
          -- , ("Greyhound Thruster", 34, 184, 0)
          -- , ("Impala Steering", 43, 0, 9440)
          -- , ("Impala Thruster", 58, 354, 0)
          -- , ("Orca Steering", 74, 0, 18120)
          -- , ("Orca Thruster", 98, 679, 0)
          -- , ("Tyrant Steering", 125, 0, 34790)
          -- , ("Tyrant Thruster", 167, 1305, 0)
          , ("A120 Thruster", 22, 154, 0)
          , ("A125 Steering", 16, 0, 3920)
          , ("A250 Thruster", 34, 273, 0)
          -- , ("A255 Steering", 25, 0, 6870)
          -- , ("A370 Thruster", 53, 476, 0)
          -- , ("A375 Steering", 38, 0, 11920)
          -- , ("A520 Thruster", 82, 819, 0)
          , ("A525 Steering", 60, 0, 20500)
          , ("A860 Thruster", 127, 1397, 0)
          , ("A865 Steering", 92, 0, 35090)
          , ("Baellie", 24, 101, 2500) -- hai
          , ("Basrem Thruster", 18, 132, 0)
          -- , ("Benga Thruster", 28, 236, 0)
          -- , ("Biroo Thruster", 44, 415, 0)
          , ("Bondir Thruster", 63, 661, 0)
          , ("Bufaer Thruster", 104, 1201, 0)
          , ("Basrem Steering", 12, 0, 3090)
          -- , ("Benga Steering", 20, 0, 5770)
          -- , ("Biroo Steering", 32, 0, 10540)
          , ("Bondir Steering", 49, 0, 17580)
          , ("Bufaer Steering", 76, 0, 30430)
          -- , ("Coalition Large Steering", 25, 0, 7119) -- coalition
          -- , ("Coalition Large Thruster", 32, 262, 0)
          -- , ("Coalition Small Steering", 7, 0, 1788)
          -- , ("Coalition Small Thruster", 9, 66, 0)
          -- , ("Korath Asteroid Steering", 10, 0, 2800) -- Korath
          -- , ("Korath Asteroid Thruster", 14, 112, 0)
          -- , ("Korath Comet Steering", 18, 0, 5688)
          -- , ("Korath Comet Thruster", 24, 218, 0)
          , ("Korath Lunar Steering", 30, 0, 10560)
          , ("Korath Lunar Thruster", 40, 412, 0)
          , ("Korath Planetary Steering", 52, 0, 20696)
          , ("Korath Planetary Thruster", 69, 800, 0)
          , ("Korath Stellar Steering", 89, 0, 40050)
          , ("Korath Stellar Thruster", 118, 1534, 0)
          -- , ("Pug Akfar Thruster", 43, 280, 0) -- pug
          -- , ("Pug Akfar Steering", 33, 0, 7500)
          -- , ("Pug Cormet Thruster", 60, 440, 0)
          -- , ("Pug Comet Steering", 46, 0, 11300)
          -- , ("Pug Lohmar Thruster", 84, 660, 0)
          -- , ("Pug Lohmar Steering", 64, 0, 17000)
          -- , ("Quarg Medium Thruster", 70, 800, 0) -- quarg
          -- , ("Quarg Medium Steering", 50, 0, 16000)
          -- , ("Crucible Thruster", 20, 180, 0) -- remnant
          -- , ("Crucible Steering", 14, 0, 4480)
          -- , ("Forge Thruster", 39, 370, 0)
          -- , ("Forge Steering", 28, 0, 9520)
          -- , ("Smelter Thruster", 76, 768, 0)
          -- , ("Smelter Steering", 55, 0, 19800)
          -- , ("Type 1 Radiant Thruster", 12, 66, 0) -- wanderer
          -- , ("Type 1 Radiant Steering", 9, 0, 1728)
          -- , ("Type 2 Radiant Thruster", 27, 176, 0)
          -- , ("Type 2 Radiant Steering", 20, 0, 4540)
          -- , ("Type 3 Radiant Thruster", 42, 315, 0)
          -- , ("Type 3 Radiant Steering", 30, 0, 7860)
          -- , ("Type 4 Radiant Thruster", 64, 552, 0)
          -- , ("Type 4 Radiant Steering", 47, 0, 13959)
          ]
