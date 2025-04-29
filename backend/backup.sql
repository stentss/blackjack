/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.11-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: rhnguyen
-- ------------------------------------------------------
-- Server version	10.11.11-MariaDB-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Comment`
--

DROP TABLE IF EXISTS `Comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Comment` (
  `CommentID` int(11) NOT NULL AUTO_INCREMENT,
  `CommentText` text NOT NULL,
  `CreatedAt` datetime NOT NULL,
  `UserID` int(11) NOT NULL,
  `EducationalContent_ID` int(11) NOT NULL,
  PRIMARY KEY (`CommentID`),
  KEY `UserID` (`UserID`),
  KEY `EducationalContent_ID` (`EducationalContent_ID`),
  CONSTRAINT `Comment_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`),
  CONSTRAINT `Comment_ibfk_2` FOREIGN KEY (`EducationalContent_ID`) REFERENCES `EducationalContent` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Comment`
--

LOCK TABLES `Comment` WRITE;
/*!40000 ALTER TABLE `Comment` DISABLE KEYS */;
INSERT INTO `Comment` VALUES
(6,'Hola','2025-04-28 03:29:00',5,13);
/*!40000 ALTER TABLE `Comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EducationalContent`
--

DROP TABLE IF EXISTS `EducationalContent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `EducationalContent` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `ContentType` varchar(50) NOT NULL,
  `ContentURL` text DEFAULT NULL,
  `ContentText` text DEFAULT NULL,
  `CreatedAt` date NOT NULL,
  `CreatedBy` int(11) NOT NULL,
  `TopicID` int(11) NOT NULL,
  `IsApproved` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`),
  KEY `CreatedBy` (`CreatedBy`),
  KEY `fk_topic_content` (`TopicID`),
  CONSTRAINT `EducationalContent_ibfk_1` FOREIGN KEY (`CreatedBy`) REFERENCES `User` (`UserID`),
  CONSTRAINT `EducationalContent_ibfk_2` FOREIGN KEY (`TopicID`) REFERENCES `Topic` (`TopicID`),
  CONSTRAINT `fk_topic_content` FOREIGN KEY (`TopicID`) REFERENCES `Topic` (`TopicID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EducationalContent`
--

LOCK TABLES `EducationalContent` WRITE;
/*!40000 ALTER TABLE `EducationalContent` DISABLE KEYS */;
INSERT INTO `EducationalContent` VALUES
(4,'test','pdf','test','test','2025-04-01',1,5,1),
(6,'pdf example','pdf','https://www.rd.usda.gov/sites/default/files/pdf-sample_0.pdf','a','2025-04-01',3,5,1),
(7,'The Fastest Way to Memorize Blackjack Basic Strategy','video','https://www.youtube.com/watch?v=PhqyZbiH3UY','','2025-04-01',1,5,1),
(8,'a','pdf','https://www.rd.usda.gov/sites/default/files/pdf-sample_0.pdf','','2025-04-01',1,5,1),
(9,'abc','pdf','abc','','2025-04-01',3,5,1),
(12,'testtest','pdf','/static/uploads/4c4c2c7c-21a4-4dc1-9d87-d6ad6cdc23b9_CSCI_443___Advance_Data_Science_Midterm_Cheatsheet_4.pdf','test','2025-04-28',5,5,1),
(13,'More About Running Count','pdf','/static/uploads/6625dc1b-b7fa-482b-98d2-044bbe792617_Robert_Prospectus_1.pdf','','2025-04-28',5,9,1),
(14,'test','pdf','test','','2025-04-28',5,9,0);
/*!40000 ALTER TABLE `EducationalContent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Game`
--

DROP TABLE IF EXISTS `Game`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Game` (
  `GameID` int(11) NOT NULL,
  `RoundNumber` int(11) NOT NULL,
  `UserAction` varchar(100) NOT NULL,
  `DealerHand` text NOT NULL,
  `UserHand` text NOT NULL,
  `Result` text NOT NULL,
  `SessionID` int(11) NOT NULL,
  PRIMARY KEY (`GameID`),
  KEY `SessionID` (`SessionID`),
  CONSTRAINT `Game_ibfk_1` FOREIGN KEY (`SessionID`) REFERENCES `Session` (`SessionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Game`
--

LOCK TABLES `Game` WRITE;
/*!40000 ALTER TABLE `Game` DISABLE KEYS */;
/*!40000 ALTER TABLE `Game` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Session`
--

DROP TABLE IF EXISTS `Session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Session` (
  `SessionID` int(11) NOT NULL AUTO_INCREMENT,
  `StartTime` int(11) NOT NULL,
  `EndTime` int(11) NOT NULL,
  `Status` varchar(50) NOT NULL,
  `TotalWagered` int(11) NOT NULL,
  `TotalWon` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  PRIMARY KEY (`SessionID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `Session_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Session`
--

LOCK TABLES `Session` WRITE;
/*!40000 ALTER TABLE `Session` DISABLE KEYS */;
/*!40000 ALTER TABLE `Session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Statistics`
--

DROP TABLE IF EXISTS `Statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Statistics` (
  `StatisticsID` int(11) NOT NULL,
  `SessionCount` int(11) NOT NULL,
  `TotalWagered` int(11) NOT NULL,
  `TotalWon` int(11) NOT NULL,
  `WinPercentage` double(5,2) NOT NULL,
  `AverageBet` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  PRIMARY KEY (`StatisticsID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `Statistics_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Statistics`
--

LOCK TABLES `Statistics` WRITE;
/*!40000 ALTER TABLE `Statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `Statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Topic`
--

DROP TABLE IF EXISTS `Topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Topic` (
  `TopicID` int(11) NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  `CreatedBy` int(11) NOT NULL,
  `CreatedAt` datetime NOT NULL,
  `IsApproved` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`TopicID`),
  KEY `CreatedBy` (`CreatedBy`),
  CONSTRAINT `Topic_ibfk_1` FOREIGN KEY (`CreatedBy`) REFERENCES `User` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Topic`
--

LOCK TABLES `Topic` WRITE;
/*!40000 ALTER TABLE `Topic` DISABLE KEYS */;
INSERT INTO `Topic` VALUES
(5,'topic1','aaa',1,'2025-04-01 03:04:07',1),
(8,'Test','test',5,'2025-04-28 02:40:16',0),
(9,'Running Count','The simple total count based on cards seen so far',5,'2025-04-28 03:23:09',1);
/*!40000 ALTER TABLE `Topic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `User` (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `Email` varchar(255) NOT NULL,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Usertype` varchar(50) NOT NULL,
  `SecurityQuestion` text NOT NULL,
  `SecurityAnswer` text NOT NULL,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES
(1,'wearinu@gmail.com','rhnguyen','scrypt:32768:8:1$8t9T5lGpTjoWGEvZ$6932fc1807136c9b193be6b636977925cc27d394873240d00057a9df771b07373a03ccd78c2b48096b787954d66bc801c76d64be9ac9d888f8bbee868faa6156','admin','What is your mother\'s maiden name?','scrypt:32768:8:1$RBLycKpfecaE4oZr$1853dd4eaac318986ec5a352c3c9088e7acfefe8291aa50dbcc847c4f99d3ee193bb26da16d8978dab2465330f58515a972d06ba974a30a988b3bdaeeee0565f'),
(3,'123@gmail.com','abc','scrypt:32768:8:1$QgDywwNqFvs7dK09$e6033c50551c700c9f351b57200691588c20e165fb4873d84bea3bc86a5e35afbb145c25a7e12c91e298df16ed9668d2f82494369dfec598d872a764777b9a93','player','What was the name of your first pet?','scrypt:32768:8:1$WS1U4UuxYMpKIYNZ$a9adb786b1cab4153a981836778538dd1c05c724a72ce64d295ab8fdc0035818f27d5852612377ab62370877fe733a036231c5b5edc3a913f959ae6faadae9fd'),
(4,'testtest@gmail.com','test','scrypt:32768:8:1$odPyTZn6dYRIR6ig$f4b7b12382f50d6295e8641fefb5dcf7b090466abd08e3b38be23dbe0d9eaf3f679dec0bfae3d7146e7a875662cdd2861c7c282644541b07b45f72f8c347c608','player','What was the name of your first pet?','scrypt:32768:8:1$EG2wZz32NU4ibGwe$d398abceacd7b5264c58106a224882e9e723713cd08e808ea77d17ea395601832c612e3f0c81f76007796704fd0a0f0f1dc57a5b88e9bc23b96485366d577bfc'),
(5,'admin@gmail.com','admin','scrypt:32768:8:1$h2qNjlM8iSoVXCuL$f03695fbc8d29507721676beb370e16bf49603e9b18aa18e9d07782461cf35cfbddada9cada650307ecfcfcffc77ba9e181bbb7378b11e27fbb2b252e8951b71','admin','What is your mother\'s maiden name?','scrypt:32768:8:1$28p9sapumOYCemQG$c1f5e6d54303889fa12f4902af0d38dc629851e9dbe73b168ebfaad6c71be48acb3fa8a969e865a28ddd58b70d1d5bc2734c8ce949ed67aa4c0bee7379d2d557');
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-28  3:59:32
