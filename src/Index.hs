{-# LANGUAGE OverloadedStrings #-}

module Index where

import Common
import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map, elemIndex)
import Control.Monad(mapM_)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uFromString, Int64, Seq, Utf8)
import Text.ProtocolBuffers (getVal)
import Data.Sequence(fromList)
import Text.ProtocolBuffers.WireMessage (messagePut)
import Data.Binary (encode)
import Data.Binary.Get (Get, getWord64be)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

indexFile :: String -> IO ()
indexFile f = do
	csv <- parseCSVFromFile f
	case csv of
		Right d -> decodeFile d
		Left err -> putStrLn "File has no data"

decodeFile :: CSV -> IO ()
decodeFile csv = do
	putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
	let entries = filter (isJust) $ map (buildEntry) csv
	let byteEntries = map (messagePut . fromJust) entries
	let byteEntrySizes = deltaEncode $ map (ByteString.length) byteEntries
	let terms = map (uParseTerm . getSearchTerm . fromJust) entries
	let header = messagePut $ buildHeader terms byteEntrySizes
	let headerSize = ByteString.length header :: Int64

	writeToFile $ encode headerSize
	writeToFile header
	mapM_ (writeToFile) byteEntries

	where
		writeToFile = ByteString.appendFile "/tmp/test.pbf" 

getSearchTerm :: Entry.Entry -> Utf8
getSearchTerm e = getVal e Entry.term

buildHeader :: [Utf8] -> [Int64] -> Header.Header
buildHeader e s = Header.Header (fromList e) (fromList s)

buildEntry :: [Field] -> Maybe Entry.Entry
buildEntry (st:lat:lon:src:_) = Just $ Entry.Entry (uFromString st) (uFromString lat) (uFromString lon) (uFromString src)
buildEntry [x] = Nothing
buildEntry [] = Nothing
