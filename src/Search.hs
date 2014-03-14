{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.List(map)
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uToString, uFromString, Int64, Utf8)
import Text.ProtocolBuffers (getVal)
import Text.ProtocolBuffers.WireMessage (messageGet)
import Data.Binary (decode)
import Data.Binary.Get (Get, getWord64be, getByteString, getLazyByteString, runGet, bytesRead, skip)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, length, drop)
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Sequence(elemIndexL,fromList)
import Data.Int
import qualified Data.Map as M

getEntry :: Int64 -> Get Entry.Entry
getEntry entrySize = do
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right (entry,_) = messageGet entryBytes ::  Either String (Entry.Entry, ByteString)
    return entry

{-getHeader :: Get ((M.Map String (Int64, Int64)), Int64)-}
{-getHeader = do-}
    {-len <- getWord64be-}
    {-headerBytes <- getLazyByteString (fromIntegral len)-}
    {-let header = decode headerBytes :: M.Map String (Int64, Int64)-}
    {-offset <- bytesRead-}
    {-return (header, offset)-}

{-search :: String -> IO ()-}
{-search s = do-}
	{-handle <- ByteString.readFile "/tmp/test.pbf"-}
	{-let (header, hoffset) = runGet getHeader handle-}
	{-case (M.lookup (parseTerm' s) header) of-}
		{-Just (o,s) -> do-}
			{-let entryData = ByteString.drop (fromIntegral (hoffset + o)) handle-}
			{-let entry = runGet (getEntry s) entryData-}
			{-print entry-}
		{-Nothing -> print "Does not exist"-}



search :: String -> IO ()
search s = do
  handle <- ByteString.readFile "/tmp/test.pbf"
  let (header, hoffset) = runGet getHeader handle
  {-let subIndexLocation = snd $ filter (\rt -> (fst rt) == s) header !! 0-}
  case (M.lookup s header) of
    Just (o,s) -> do
      let subIndexData = ByteString.drop (fromIntegral (hoffset + o)) handle
      let subIndex = runGet (getSubIndex s) subIndexData
      print subIndex
    Nothing -> print "Does not exist"
  print "done"


	{-case (M.lookup (parseTerm' s) header) of-}
		{-Just (o,s) -> do-}
			{-let entryData = ByteString.drop (fromIntegral (hoffset + o)) handle-}
			{-let entry = runGet (getEntry s) entryData-}
			{-print entry-}
		{-Nothing -> print "Does not exist"-}


getSubIndex :: Int64 -> Get (M.Map String [(Int64, Int64)])
getSubIndex subIndexSize = do
    subIndexBytes <- getLazyByteString (fromIntegral subIndexSize)
    let subIndex = decode subIndexBytes :: (M.Map String [(Int64, Int64)])
    return subIndex

getHeader :: Get ((M.Map String (Int64, Int64)), Int64)
getHeader = do
    len <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral len)
    let header = decode headerBytes :: (M.Map String (Int64, Int64))
    offset <- bytesRead
    return (header, offset)


