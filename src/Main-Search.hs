{-# LANGUAGE OverloadedStrings #-}

import           Control.Monad        (when)
import           Data.ProtocolBuffers (getField)
import qualified Data.Text            as T
import           Proto
import           Search
import           System.Environment   (getArgs)
import           System.Exit          (exitFailure)
import           System.IO            (hPutStrLn, stderr)

main :: IO ()
main = do
  args <- getArgs
  when (length args < 2) showUsage
  let indexFile = head args
  let term = args !! 1
  results <- search indexFile term
  mapM_ (printEntry) results
  putStrLn $ ""
  putStrLn $ show (length results) ++ " Results Found"


printEntry entry = do
  let latStr = (show . getField $ latitude entry)
  let lonStr = (show . getField $ longitude entry)
  let rankStr = (show . getField $ rank entry)
  putStrLn $ ""
  putStrLn $ "##################################################"
  putStrLn $ "# Term:                   " ++ (T.unpack . getField $ term entry)
  putStrLn $ "# Latitude:               " ++ latStr
  putStrLn $ "# Longitude:              " ++ lonStr
  putStrLn $ "# Source:                 " ++ (T.unpack . getField $ src entry)
  putStrLn $ "# Rank:                   " ++ rankStr
  putStrLn $ "# Type:                   " ++ (T.unpack . getField $ type' entry)
  mapM_ (printTag) $ getField $ tags entry
  putStrLn $ "# Open Streetmap:         " ++ ("http://www.openstreetmap.org/#map=15/" ++ latStr ++ "/" ++ lonStr)
  putStrLn $ "# Here:                   " ++ ("http://here.com/" ++ latStr ++ "," ++ lonStr ++ ",15,0,0,normal.day")
  putStrLn $ "# Google Maps:            " ++ ("http://www.google.co.uk/maps/@" ++ latStr ++ "," ++ lonStr ++ ",15z")
  putStrLn $ "##################################################"
  where
    printTag tag = do
      putStrLn $ "# Tag:                    " ++ (T.unpack . getField $ key tag) ++ " = " ++ (T.unpack . getField $ value tag)

showUsage :: IO ()
showUsage = do
  hPutStrLn stderr "usage: indexFile term"
  hPutStrLn stderr "example: geo-search geodata.idx 'LEEDS'"
  exitFailure
