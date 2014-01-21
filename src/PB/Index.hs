{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
module PB.Index (protoInfo, fileDescriptorProto) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import Text.DescriptorProtos.FileDescriptorProto (FileDescriptorProto)
import Text.ProtocolBuffers.Reflections (ProtoInfo)
import qualified Text.ProtocolBuffers.WireMessage as P' (wireGet,getFromBS)
 
protoInfo :: ProtoInfo
protoInfo
 = Prelude'.read
    "ProtoInfo {protoMod = ProtoName {protobufName = FIName \".Indexformat\", haskellPrefix = [], parentModule = [MName \"PB\"], baseName = MName \"Index\"}, protoFilePath = [\"PB\",\"Index.hs\"], protoSource = \"indexformat.proto\", extensionKeys = fromList [], messages = [DescriptorInfo {descName = ProtoName {protobufName = FIName \".Indexformat.Entry\", haskellPrefix = [], parentModule = [MName \"PB\",MName \"Index\"], baseName = MName \"Entry\"}, descFilePath = [\"PB\",\"Index\",\"Entry.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.term\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"term\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.latitude\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"latitude\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 18}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.longitude\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"longitude\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 26}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Indexformat.Entry.src\", haskellPrefix' = [], parentModule' = [MName \"PB\",MName \"Index\",MName \"Entry\"], baseName' = FName \"src\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 34}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}], enums = [], knownKeyMap = fromList []}"
 
fileDescriptorProto :: FileDescriptorProto
fileDescriptorProto
 = P'.getFromBS (P'.wireGet 11)
    (P'.pack
      "x\n\DC1indexformat.proto\"G\n\ENQEntry\DC2\f\n\EOTterm\CAN\SOH \STX(\t\DC2\DLE\n\blatitude\CAN\STX \STX(\t\DC2\DC1\n\tlongitude\CAN\ETX \STX(\t\DC2\v\n\ETXsrc\CAN\EOT \STX(\tB\SUB\n\bPB.IndexH\SOHP\NUL\128\SOH\NUL\136\SOH\NUL\144\SOH\NUL\160\SOH\NUL")