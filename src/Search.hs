{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.List(map, elemIndex)
import qualified PB.Index.Header as Header
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uToString, uFromString, Int64, Utf8)
import Text.ProtocolBuffers (getVal)
import Text.ProtocolBuffers.WireMessage (messageGet)
import Data.Binary.Get (Get, getWord64be, getByteString, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, length, drop)
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Sequence(elemIndexL,fromList)
import Data.Int
import qualified Data.Map as M

search :: String -> IO ()
search s = do
	handle <- ByteString.readFile "/tmp/test.pbf"
	let (header, hoffset) = runGet getHeader handle
	let terms = getVal header Header.term 
	let sizes = deltaDecode $ toList $ getVal header Header.size
	case (elemIndexL (parseTerm s) terms) of
		Just i -> do
			let entrySize = sizes !! i
			let offset = hoffset + (foldl1 (+) (take i sizes))
			let entryData = ByteString.drop (fromIntegral offset) handle
			let entry = runGet (getEntry entrySize) entryData
			print entry
		Nothing -> print "Does not exist"

getHeader :: Get (Header.Header, Int64)
getHeader = do
    len <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral len)
    let Right (header,_) = messageGet headerBytes ::  Either String (Header.Header, ByteString)
    offset <- bytesRead
    return (header, offset)

getEntry :: Int64 -> Get Entry.Entry
getEntry entrySize = do
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right (entry,_) = messageGet entryBytes ::  Either String (Entry.Entry, ByteString)
    return entry


--search' :: String -> IO ()
--search' s = do
--	handle <- ByteString.readFile "/tmp/test.pbf"
--	let (header, hoffset) = runGet getHeader handle
--	let terms = toList $ getVal header Header.term 
--	let sizes = deltaDecode $ toList $ getVal header Header.size
--	let dataMap = M.fromList $ zip terms sizes
--	case (M.lookup (parseTerm s) dataMap) of
--		Just i -> do
--			let entrySize = i
--			--let offset = hoffset + (foldl1 (+) (take i sizes))
--			--let entryData = ByteString.drop (fromIntegral offset) handle
--			--let entry = runGet (getEntry entrySize) entryData
--			print entrySize
--		Nothing -> print "Does not exist"












