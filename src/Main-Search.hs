{-# LANGUAGE OverloadedStrings #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad(when)

main :: IO ()
main = do 
	args <- getArgs
	when (length args < 2) showUsage
	let indexFile = args !! 0
	let term = args !! 1
	search indexFile term

showUsage :: IO ()
showUsage = do
      hPutStrLn stderr "usage: indexFile term"
      hPutStrLn stderr "example: geo-search geodata.idx 'LEEDS'"
      exitFailure

