{-# LANGUAGE OverloadedStrings #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad(when)
import PB.Index.Entry
import PB.Index.Tag
import Common
import Data.Foldable (toList)
import Text.ProtocolBuffers.Basic (uToString)

main :: IO ()
main = do 
  args <- getArgs
  when (length args < 2) showUsage
  let indexFile = head args
  let term = args !! 1
  results <- search indexFile term
  mapM_ (printEntry) results

printEntry entry = do
  let t = toList $ tags entry
  putStrLn $ ""
  putStrLn $ "##################################################"
  putStrLn $ "# Term:        " ++ (uToString $ term entry)
  putStrLn $ "# Latitude:    " ++ (uToString $ latitude entry)
  putStrLn $ "# Longitude:   " ++ (uToString $ longitude entry)
  putStrLn $ "# Source:      " ++ (uToString $ src entry)
  putStrLn $ "# Rank:        " ++ (uToString $ rank entry)
  putStrLn $ "# Type:        " ++ (uToString $ type' entry)
  mapM_ (printTag) t
  putStrLn $ "##################################################"
  putStrLn $ ""
  where
    printTag tag = do
      let p = sParseTerm
      putStrLn $ "# Tag:         " ++ (uToString $ key tag) ++ " = " ++ (uToString $ value tag) 

showUsage :: IO ()
showUsage = do
  hPutStrLn stderr "usage: indexFile term"
  hPutStrLn stderr "example: geo-search geodata.idx 'LEEDS'"
  exitFailure

