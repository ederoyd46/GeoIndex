{-# LANGUAGE OverloadedStrings #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad(when, forever)

main :: IO ()
main = do 
	putStrLn "Enter search term: " 
	forever $ do
		term <- getLine
		search term
