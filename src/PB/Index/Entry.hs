{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
module PB.Index.Entry (Entry(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
 
data Entry = Entry{term :: !P'.Utf8, latitude :: !P'.Utf8, longitude :: !P'.Utf8, src :: !P'.Utf8}
           deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable Entry where
  mergeAppend (Entry x'1 x'2 x'3 x'4) (Entry y'1 y'2 y'3 y'4)
   = Entry (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
 
instance P'.Default Entry where
  defaultValue = Entry P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue
 
instance P'.Wire Entry where
  wireSize ft' self'@(Entry x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeReq 1 9 x'1 + P'.wireSizeReq 1 9 x'2 + P'.wireSizeReq 1 9 x'3 + P'.wireSizeReq 1 9 x'4)
  wirePut ft' self'@(Entry x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 10 9 x'1
             P'.wirePutReq 18 9 x'2
             P'.wirePutReq 26 9 x'3
             P'.wirePutReq 34 9 x'4
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{term = new'Field}) (P'.wireGet 9)
             18 -> Prelude'.fmap (\ !new'Field -> old'Self{latitude = new'Field}) (P'.wireGet 9)
             26 -> Prelude'.fmap (\ !new'Field -> old'Self{longitude = new'Field}) (P'.wireGet 9)
             34 -> Prelude'.fmap (\ !new'Field -> old'Self{src = new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self
 
instance P'.MessageAPI msg' (msg' -> Entry) Entry where
  getVal m' f' = f' m'
 
instance P'.GPB Entry
 
instance P'.ReflectDescriptor Entry where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [10, 18, 26, 34]) (P'.fromDistinctAscList [10, 18, 26, 34])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Indexformat.Entry\", haskellPrefix = [], parentModule = [MName \"PB\",MName \"Index\"], baseName = MName \"Entry\"}, descFilePath = [\"PB\",\"Index\",\"Entry.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.term\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"term\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.latitude\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"latitude\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.longitude\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"longitude\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 26}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.src\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"src\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 34}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}"