{-# LANGUAGE OverloadedStrings #-}

import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map)
import Control.Monad(mapM_)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (uFromString, Int64, Seq, Utf8)
import Text.ProtocolBuffers (getVal)
import Data.Sequence(fromList)
import Text.ProtocolBuffers.WireMessage (messageGet, messagePut)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)

--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

main :: IO ()
main = do
	csv <- parseCSVFromFile "/var/development/geodata-small.csv"
	case csv of
		Right d -> decodeFile d
		Left err -> putStrLn "File has no data"

decodeFile :: CSV -> IO ()
decodeFile csv = do
	putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
	let rows = filter (isJust) $ map (buildEntry) csv
	let bin = map (messagePut . fromJust) rows
	let terms = map (getSearchTerm . fromJust) rows
	let size = deltaEncode $ map (ByteString.length) bin
	print $ buildIndexHeader terms size
	writeToFile $ messagePut $ buildIndexHeader terms size
	mapM_ (writeToFile) bin

	where
		writeToFile = ByteString.appendFile "/tmp/test.pbf"

getSearchTerm :: Entry.Entry -> Utf8
getSearchTerm e = getVal e Entry.term

buildIndexHeader :: [Utf8] -> [Int64] -> Header.Header
buildIndexHeader e s = Header.Header (fromList e) (fromList s)

buildEntry :: [Field] -> Maybe Entry.Entry
buildEntry (st:lat:lon:src:_) = Just $ Entry.Entry (uFromString st) (uFromString lat) (uFromString lon) (uFromString src)
buildEntry [x] = Nothing
buildEntry [] = Nothing

deltaEncode :: [Int64] -> [Int64]
deltaEncode a = head a : (zipWith (-) (tail a) a)

deltaDecode :: [Int64] -> [Int64]
deltaDecode a = scanl1 (+) a
