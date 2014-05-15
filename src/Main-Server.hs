{-# LANGUAGE OverloadedStrings #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad(when, forever)

main :: IO ()
main = do 
  args <- getArgs
  when (length args < 1) showUsage
  let indexFile = head args
  putStrLn "Enter search term: " 
  forever $ do
    term <- getLine
    results <- search indexFile term
    mapM_ (print) results

showUsage :: IO ()
showUsage = do
      hPutStrLn stderr "usage: indexFile"
      hPutStrLn stderr "example: geo-server geodata.idx"
      exitFailure

