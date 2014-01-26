{-# LANGUAGE OverloadedStrings #-}

module Common where

import Data.Int

deltaEncode :: [Int64] -> [Int64]
deltaEncode a = head a : (zipWith (-) (tail a) a)

deltaDecode :: [Int64] -> [Int64]
deltaDecode a = scanl1 (+) a

