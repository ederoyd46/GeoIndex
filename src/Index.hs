{-# LANGUAGE OverloadedStrings #-}

module Index where

import Common
import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map, elemIndex)
import qualified Data.Map as M
import Control.Monad(mapM_)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uFromString, uToString, Int64, Seq, Utf8)
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

getSearchTerm :: Entry.Entry -> Utf8
getSearchTerm e = getVal e Entry.term

buildHeader :: [Utf8] -> [Int64] -> Header.Header
buildHeader e s = Header.Header (fromList e) (fromList s)

buildEntry :: [Field] -> Maybe Entry.Entry
buildEntry (st:lat:lon:src:_) = Just $ Entry.Entry (uFromString st) (uFromString lat) (uFromString lon) (uFromString src)
buildEntry [x] = Nothing
buildEntry [] = Nothing

indexFile :: String -> IO ()
indexFile f = do
	csv <- parseCSVFromFile f
	case csv of
		Right d -> decodeFile d
		Left err -> putStrLn "File has no data"

--Needs a tidy up!! -- Put on some types so we know what we've got
decodeFile :: CSV -> IO ()
decodeFile csv = do
	putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
	let entries = filter (isJust) $ map (buildEntry) csv
	let byteEntries = map (messagePut . fromJust) entries
	let byteEntrySizes = map (ByteString.length) byteEntries
	let terms = map (sParseTerm . getSearchTerm . fromJust) entries :: [String]
	let byteOffsets = scanl (+) 0 byteEntrySizes :: [Int64]
	let termsMap = (M.fromList $ zip terms (zip byteOffsets byteEntrySizes)) :: M.Map String (Int64, Int64)
	let header = encode termsMap
	let headerSize = ByteString.length header :: Int64
	
	writeToFile $ encode headerSize
	writeToFile header
	mapM_ (writeToFile) byteEntries

	where
		writeToFile = ByteString.appendFile "/tmp/test.pbf" 

