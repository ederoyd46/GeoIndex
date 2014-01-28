{-# LANGUAGE OverloadedStrings #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad(when)


main :: IO ()
main = do 
	args <- getArgs
	when (length args < 1) showUsage
	let term = args !! 0
	search' term


showUsage :: IO ()
showUsage = do
      hPutStrLn stderr "usage: term"
      hPutStrLn stderr "example: Geo-Search 'LEEDS' "
      exitFailure

