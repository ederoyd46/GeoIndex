{-# LANGUAGE OverloadedStrings #-}

import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map, elemIndex)
import Control.Monad(mapM_)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uFromString, uToString, Int64, Seq, Utf8)
import Text.ProtocolBuffers (getVal)
import Data.Sequence(fromList)
import Text.ProtocolBuffers.WireMessage (messageGet, messagePut)
import Data.Binary (encode)
import Data.Binary.Get (Get, getWord64be, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)

import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)

--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

main :: IO ()
main = do
	csv <- parseCSVFromFile "/var/development/geodata.csv"
	case csv of
		Right d -> decodeFile d
		Left err -> putStrLn "File has no data"

decodeFile :: CSV -> IO ()
decodeFile csv = do
	putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
	let entries = filter (isJust) $ map (buildEntry) csv
	let byteEntries = map (messagePut . fromJust) entries
	let byteEntrySizes = deltaEncode $ map (ByteString.length) byteEntries
	let terms = map (getSearchTerm . fromJust) entries
	let header = messagePut $ buildIndexHeader terms byteEntrySizes
	let headerSize = ByteString.length header :: Int64

	writeToFile $ encode headerSize
	writeToFile header
	mapM_ (writeToFile) byteEntries

	searchFile "LEEDS"

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

searchFile :: String -> IO ()
searchFile s = do
	handle <- ByteString.readFile "/tmp/test.pbf"
	let header = runGet getHeader handle
	let terms = map (uToString) $ toList $ getVal (fst header) Header.term 
	let sizes = deltaDecode $ toList $ getVal (fst header) Header.size 
	case (elemIndex s terms) of
		Just i -> do
			let offset = (snd header) + (foldl1 (+) (take i sizes))
			let entrySize = sizes !! i
			let entry = runGet (getEntry offset entrySize) handle
			print entry
		Nothing -> print "Does not exist"



getHeader :: Get (Header.Header, Int64)
getHeader = do
    len <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral len)
    let Right (header,_) = messageGet headerBytes ::  Either String (Header.Header, ByteString)
    offset <- bytesRead
    return (header, offset)

getEntry :: Int64 -> Int64 -> Get Entry.Entry
getEntry offset entrySize = do
    _ <- skip $ fromIntegral offset
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right (entry,_) = messageGet entryBytes ::  Either String (Entry.Entry, ByteString)
    return entry


