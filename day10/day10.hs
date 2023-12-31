module Main where

import Control.Monad (msum)
import Data.Array
import Data.Bifunctor (bimap, second)
import Data.List qualified as L
import Data.Maybe (fromJust)
import Data.Monoid (First)
import Debug.Trace (trace)

type Grid = Array Int (Array Int Char)

type Point = (Int, Int)

data Direction = North | South | West | East deriving (Enum, Show)

parse :: [String] -> Grid
parse ls = array (0, height - 1) $ zip [0 ..] $ map createRow ls
  where
    width = length $ head ls
    height = length ls
    createRow l = array (0, width - 1) $ zip [0 ..] l

findStart :: Grid -> Point
findStart grid = go $ assocs grid
  where
    go ((i, row) : rs) = case L.find ((== 'S') . snd) $ assocs row of
      Just (j, _) -> (i, j)
      Nothing -> go rs

connected :: Char -> Char -> Direction -> Bool
connected 'S' _ _ = True
connected _ 'S' _ = True
connected a b North = a `elem` ['|', 'L', 'J'] && b `elem` ['7', 'F', '|']
connected a b South = connected b a North
connected a b West = a `elem` ['-', 'J', '7'] && b `elem` ['-', 'L', 'F']
connected a b East = connected b a West

withinBounds :: Grid -> Point -> Bool
withinBounds grid (i, j) = 0 <= i && i <= h && 0 <= j && j <= w
  where
    (_, h) = bounds grid
    (_, w) = bounds $ head $ elems grid

getLoop :: Grid -> Point -> Point -> [Point] -> [Point]
getLoop grid p@(i, j) (pi, pj) path | grid ! i ! j == 'S' && (i /= pi || j /= pj) = [p]
getLoop grid p@(i, j) prev path = case moveable of
  [] -> []
  _ -> p : rest
  where
    neighbors = zipWith (curry $ second $ bimap (+ i) (+ j)) [North ..] [(-1, 0), (1, 0), (0, -1), (0, 1)]
    at (y, x) = grid ! y ! x
    canMove dir to = to /= prev && withinBounds grid to && connected (at p) (at to) dir
    moveable = map snd $ filter (uncurry canMove) neighbors
    rest = head $ filter (not . null) $ map (\adj -> getLoop grid adj p path) moveable

solve1 :: Grid -> Int
solve1 grid = length loop `div` 2
  where
    start = findStart grid
    loop = getLoop grid start start []

getVertices :: Grid -> [Point] -> [Point]
getVertices grid path = go path []
  where
    go (v@(i, j) : ps) acc | grid ! i ! j `elem` ['L', 'J', '7', 'F', 'S'] = go ps (v : acc)
    go (_ : ps) acc = go ps acc
    go [] acc = acc

shoelace :: [Point] -> Int
shoelace points = abs (pos - neg) `div` 2
  where
    pos = sum $ zipWith (*) (map snd points) (map fst (tail points))
    neg = sum $ zipWith (*) (map fst points) (map snd (tail points))

-- Pick's theorem
solve2 :: Grid -> Int
solve2 grid = shoelace loop - (b `div` 2) + 1
  where
    start = findStart grid
    loop = getLoop grid start start []
    b = length loop - 1

main :: IO ()
main = do
  inp <- getContents
  let ls = lines inp
  let grid = parse ls
  print $ solve1 grid
  print $ solve2 grid
