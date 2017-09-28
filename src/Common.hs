{-# LANGUAGE OverloadedStrings #-}

module Common where

import Data.Int
import Data.Char

deltaEncode :: [Int64] -> [Int64]
deltaEncode a = head a : zipWith (-) (tail a) a

deltaDecode :: [Int64] -> [Int64]
deltaDecode = scanl1 (+)

parseTerm' :: String -> String
parseTerm' = do
    let filterAlphas = map toUpper . filter (\x -> isAlphaNum x || isSpace x)
    let removeSpaces = filter isAlphaNum
    let filterWords = unwords . filter ("NEAR" /=) . filter ("IN" /=) . words
    removeSpaces . filterWords . filterAlphas

parseRootTerm :: String -> String
parseRootTerm = take 3 . parseTerm'
