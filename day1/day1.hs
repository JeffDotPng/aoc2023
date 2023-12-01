module Main where

import Data.Char (isDigit)
import Data.List (find, isPrefixOf, isSuffixOf)

digitLine :: String -> Int
digitLine s = read [firstDigit s, firstDigit (reverse s)]
  where
    firstDigit s = head $ filter isDigit s

digits :: [(String, Char)]
digits = [("one", '1'), ("two", '2'), ("three", '3'), ("four", '4'), ("five", '5'), ("six", '6'), ("seven", '7'), ("eight", '8'), ("nine", '9')]

digitLine2 :: String -> Int
digitLine2 s = read [firstDigit2 s, lastDigit2 s]
  where
    firstDigit2 s = case find ((`isPrefixOf` s) . fst) digits of
      Just (_, n) -> n
      Nothing -> let c = head s in if isDigit c then c else firstDigit2 (tail s)

    lastDigit2 s = case find ((`isSuffixOf` s) . fst) digits of
      Just (_, n) -> n
      Nothing -> let c = last s in if isDigit c then c else lastDigit2 (init s)

solve :: (String -> Int) -> [String] -> Int
solve f ss = sum $ map f ss

main :: IO ()
main = do
  inp <- getContents
  let ls = lines inp
  print (solve digitLine ls)
  print (solve digitLine2 ls)