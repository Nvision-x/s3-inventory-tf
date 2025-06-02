Inventory Configuration

Field	Required	Description
Id	✅	Unique name for the inventory configuration
IsEnabled	✅	Whether the configuration is active
IncludedObjectVersions	✅	All or Current — includes all versions or just the latest
Destination	✅	Where the inventory report is delivered (another bucket)
Schedule	✅	Frequency: Daily or Weekly
Prefix	❌	Only include objects with this key prefix
Filter	❌	More advanced filter to include only certain objects
OptionalFields	❌	List of metadata fields to include in the report

Optional Fields

"OptionalFields": 
  "Size",
  "LastModifiedDate",
  "StorageClass",
  "ETag",
  "IsMultipartUploaded",
  "ReplicationStatus",
  "EncryptionStatus",
  "ObjectLockRetainUntilDate",
  "ObjectLockMode",
  "ObjectLockLegalHoldStatus",
  "IntelligentTieringAccessTier",
  "BucketKeyStatus",
  "ChecksumAlgorithm"
