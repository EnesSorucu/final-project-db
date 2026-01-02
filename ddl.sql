SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

CREATE TABLE IF NOT EXISTS `mydb`.`generalForum` (
  `forumID` INT NOT NULL AUTO_INCREMENT, `generalForumUrl` VARCHAR(300) NOT NULL,
  PRIMARY KEY (`forumID`), UNIQUE INDEX `forumID_UNIQUE` (`forumID` ASC) VISIBLE, UNIQUE INDEX `generalForumUrl_UNIQUE` (`generalForumUrl` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`promos` (
  `promoID` INT NOT NULL AUTO_INCREMENT, `promoName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`promoID`), UNIQUE INDEX `promoName_UNIQUE` (`promoName` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`currency` (
  `currencyID` INT NOT NULL AUTO_INCREMENT, `currencyName` VARCHAR(5) NOT NULL,
  PRIMARY KEY (`currencyID`), UNIQUE INDEX `currencyID_UNIQUE` (`currencyID` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`game` (
  `gameID` INT NOT NULL, `title` VARCHAR(200) NOT NULL, `price` DECIMAL(10,2) NOT NULL,
  `currencyID` INT NOT NULL, `marketUrl` VARCHAR(500) NOT NULL, `availability` JSON NOT NULL,
  `filteredAvgRating` DECIMAL(10,2) NOT NULL, `overallAvgRating` DECIMAL(10,2) NOT NULL,
  `supportUrl` VARCHAR(300) NOT NULL, `gallery` JSON NOT NULL, `video` JSON NULL,
  `image` LONGTEXT NOT NULL, `boxImage` LONGTEXT NOT NULL, `forumID` INT NOT NULL, `promoID` INT NULL,
  PRIMARY KEY (`gameID`), UNIQUE INDEX `id_UNIQUE` (`gameID` ASC) VISIBLE,
  INDEX `fk_game_forum_idx` (`forumID` ASC) VISIBLE, INDEX `fk_game_promo_idx` (`promoID` ASC) VISIBLE,
  INDEX `idx_game_title` (`title` ASC) VISIBLE, INDEX `idx_game_price` (`price` ASC) VISIBLE,
  INDEX `fk_game_curr_idx` (`currencyID` ASC) VISIBLE,
  CONSTRAINT `fk_game_forum` FOREIGN KEY (`forumID`) REFERENCES `mydb`.`generalForum` (`forumID`),
  CONSTRAINT `fk_game_promo` FOREIGN KEY (`promoID`) REFERENCES `mydb`.`promos` (`promoID`),
  CONSTRAINT `fk_game_curr` FOREIGN KEY (`currencyID`) REFERENCES `mydb`.`currency` (`currencyID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`publisher` (
  `publisherID` INT NOT NULL AUTO_INCREMENT, `publisher` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`publisherID`), UNIQUE INDEX `publisher_UNIQUE` (`publisher` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`genres` (
  `genreID` INT NOT NULL AUTO_INCREMENT, `genre` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`genreID`), UNIQUE INDEX `genre_UNIQUE` (`genre` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`developer` (
  `developerID` INT NOT NULL AUTO_INCREMENT, `developer` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`developerID`), UNIQUE INDEX `developer_UNIQUE` (`developer` ASC) VISIBLE) ENGINE = InnoDB;
CREATE TABLE IF NOT EXISTS `mydb`.`developersGame` (
  `developerID` INT NOT NULL, `gameID` INT NOT NULL,
  PRIMARY KEY (`developerID`, `gameID`),
  INDEX `fk_dev_game_idx` (`gameID` ASC) VISIBLE, INDEX `fk_dev_dev_idx` (`developerID` ASC) VISIBLE,
  CONSTRAINT `fk_dev_dev` FOREIGN KEY (`developerID`) REFERENCES `mydb`.`developer` (`developerID`),
  CONSTRAINT `fk_dev_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`publishersGame` (
  `publisherID` INT NOT NULL, `gameID` INT NOT NULL,
  PRIMARY KEY (`publisherID`, `gameID`),
  INDEX `fk_pub_game_idx` (`gameID` ASC) VISIBLE, INDEX `fk_pub_pub_idx` (`publisherID` ASC) VISIBLE,
  CONSTRAINT `fk_pub_pub` FOREIGN KEY (`publisherID`) REFERENCES `mydb`.`publisher` (`publisherID`),
  CONSTRAINT `fk_pub_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`whichGenre` (
  `gameID` INT NOT NULL, `genreID` INT NOT NULL, `isPrimaryGenre` TINYINT NOT NULL,
  PRIMARY KEY (`gameID`, `genreID`),
  INDEX `fk_gen_game_idx` (`gameID` ASC) VISIBLE, INDEX `fk_gen_gen_idx` (`genreID` ASC) VISIBLE,
  CONSTRAINT `fk_gen_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`),
  CONSTRAINT `fk_gen_gen` FOREIGN KEY (`genreID`) REFERENCES `mydb`.`genres` (`genreID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`operatingSystem` (
  `systemID` INT NOT NULL AUTO_INCREMENT, `systemName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`systemID`), UNIQUE INDEX `systemName_UNIQUE` (`systemName` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`whichOperatingSystem` (
  `gameID` INT NOT NULL, `systemID` INT NOT NULL,
  PRIMARY KEY (`gameID`, `systemID`),
  INDEX `fk_os_sys_idx` (`systemID` ASC) VISIBLE, INDEX `fk_os_game_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_os_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`),
  CONSTRAINT `fk_os_sys` FOREIGN KEY (`systemID`) REFERENCES `mydb`.`operatingSystem` (`systemID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`integer_col` (
  `colID` INT NOT NULL AUTO_INCREMENT, `colName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`colID`), UNIQUE INDEX `colName_UNIQUE` (`colName` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`gamesIntegerCol` (
  `gameID` INT NOT NULL, `integerColID` INT NOT NULL, `integerValue` INT NULL,
  PRIMARY KEY (`gameID`, `integerColID`),
  INDEX `fk_int_col_idx` (`integerColID` ASC) VISIBLE, INDEX `fk_int_game_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_int_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`),
  CONSTRAINT `fk_int_col` FOREIGN KEY (`integerColID`) REFERENCES `mydb`.`integer_col` (`colID`)) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`Boolean_col` (
  `colID` INT NOT NULL AUTO_INCREMENT, `colName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`colID`), UNIQUE INDEX `colName_UNIQUE` (`colName` ASC) VISIBLE) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`gamesBooleanCol` (
  `gameID` INT NOT NULL, `booleanColID` INT NOT NULL, `booleanValue` TINYINT NOT NULL,
  PRIMARY KEY (`gameID`, `booleanColID`),
  INDEX `fk_bool_col_idx` (`booleanColID` ASC) VISIBLE, INDEX `fk_bool_game_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_bool_game` FOREIGN KEY (`gameID`) REFERENCES `mydb`.`game` (`gameID`),
  CONSTRAINT `fk_bool_col` FOREIGN KEY (`booleanColID`) REFERENCES `mydb`.`Boolean_col` (`colID`)) ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
