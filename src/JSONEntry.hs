{-# LANGUAGE OverloadedStrings #-}

module JSONEntry where

import Control.Monad(mzero)
import Control.Applicative
import qualified Data.Map as M
import Data.Aeson

data JSONEntry = JSONEntry {  term :: String
                            , latitude :: Float
                            , longitude :: Float
                            , source :: String
                            , rank :: Float
                            , type' :: String
                            , tags :: (M.Map String String)
                            } deriving (Show)

instance FromJSON JSONEntry where
     parseJSON (Object v) = JSONEntry <$>
                            v .: "searchTerm" <*>
                            v .: "latitude" <*>
                            v .: "longitude" <*>
                            v .: "source" <*>
                            v .: "rank" <*>
                            v .: "type" <*>
                            v .: "tags"
     parseJSON _ = mzero



