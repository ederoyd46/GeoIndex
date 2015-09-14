{-# LANGUAGE OverloadedStrings #-}

import Index
import Control.Monad(when)
import System.IO (hPutStrLn, stderr)
import System.Exit (exitFailure)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  when (length args < 1) showUsage
  let fileToIndex = head args
  let indexOutputFile = args !! 1
  indexFile fileToIndex indexOutputFile

showUsage :: IO ()
showUsage = do
      hPutStrLn stderr "usage: fileToIndex indexFile"
      hPutStrLn stderr "example: geo-index geodata.json geodata.idx"
      exitFailure
