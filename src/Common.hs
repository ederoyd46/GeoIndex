{-# LANGUAGE OverloadedStrings #-}

module Common where

import Data.Int
import Data.Char

import Text.ProtocolBuffers.Basic (uFromString, uToString, Utf8)

deltaEncode :: [Int64] -> [Int64]
deltaEncode a = head a : (zipWith (-) (tail a) a)

deltaDecode :: [Int64] -> [Int64]
deltaDecode a = scanl1 (+) a

uParseTerm :: Utf8 -> Utf8
uParseTerm = uFromString . parseTerm' . uToString

parseTerm :: String -> Utf8
parseTerm = uFromString . parseTerm'

sParseTerm :: Utf8 -> String
sParseTerm = parseTerm' . uToString

parseTerm' :: String -> String
parseTerm' = do
	let filterAlphas = map (toUpper) . filter (\x -> (isAlphaNum x) || (isSpace x))
	let removeSpaces = filter (isAlphaNum)
	let filterWords = unwords . filter ("NEAR" /=) . filter ("IN" /=) . words
	removeSpaces . filterWords . filterAlphas

parseRootTerm :: String -> String
parseRootTerm = take 3 . parseTerm'
