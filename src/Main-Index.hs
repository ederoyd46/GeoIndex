{-# LANGUAGE OverloadedStrings #-}

import Index
import System.Environment (getArgs)

main :: IO ()
main = indexFile "/var/development/geodata.csv" 
