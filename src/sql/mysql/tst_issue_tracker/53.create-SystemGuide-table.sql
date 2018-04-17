	DROP TABLE IF EXISTS `SystemGuide`;
	/*!40101 SET @saved_cs_client     = @@character_set_client */;
	/*!40101 SET character_set_client = utf8 */;


	CREATE TABLE `SystemGuide` (
		`SystemGuideId` 			bigint 			NOT NULL UNIQUE
	 , `Level`				smallint 		NOT NULL 
	 , `SeqId`				decimal 			NOT NULL -- because there must be order !!!
	 , `LeftRank`			bigint			NOT NULL
	 , `RightRank`			bigint			NOT NULL
	 , `Prio`				smallint 		NOT NULL DEFAULT '0'
	 , `Status` 			varchar(12) 	DEFAULT NULL
	 , `Type` 				varchar(14) 	DEFAULT NULL
	 , `Name` 				varchar(200) 	NOT NULL
	 , `Description` 		varchar(4000) 	DEFAULT NULL
	 , `SrcCode` 			varchar(4000) 	DEFAULT NULL
	 , `Comment` 			varchar(4000) 	DEFAULT NULL
	 , `UpdateTime` 		datetime 		DEFAULT NULL	
	 , `FileType` 			varchar(10) 	DEFAULT NULL
	 
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	/*!40101 SET character_set_client = @saved_cs_client */;
	DROP TRIGGER IF EXISTS `trgOnInsertSystemGuideUpdateTime` ;
	
	
	CREATE TRIGGER `trgOnInsertSystemGuideUpdateTime` BEFORE INSERT ON  `SystemGuide` 
	FOR EACH ROW 
	SET NEW.UpdateTime = NOW()
	; 
	

	DELIMITER ///

	DROP TRIGGER IF EXISTS `trgOnUpdateSystemGuideUpdateTime` ;
	CREATE TRIGGER `trgOnUpdateSystemGuideUpdateTime` BEFORE UPDATE ON  `SystemGuide` 
		FOR EACH ROW 
		BEGIN 
			-- update the update time of the SystemGuide
			SET NEW.UpdateTime = NOW() ; 
		END ;
	
	-- now check that the table exists 
	SHOW TABLES LIKE 'SystemGuide';
	
	SELECT FOUND_ROWS() AS 'FOUND'  ;

	-- NOW CHECK THE COLUMNS
	SELECT CONCAT ( TABLE_NAME  , '.' , COLUMN_NAME  )
	AS 'TABLE.COLUMNS'
	from information_schema.COLUMNS
	WHERE 1=1
	AND TABLE_SCHEMA=DATABASE()
	AND TABLE_NAME='SystemGuide' ; 




/*
-- VersionHistory
1.0.2. -- 2014-11-27 09:37:45 -- ysg -- added DocId
1.0.1. -- 2014-06-29 19:41:18 -- ysg -- removed attributes
1.0.0. -- 2014-07-19 09:43:38 -- ysg -- init 

*/