-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`generalForum`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`generalForum` (
  `forumID` INT NOT NULL AUTO_INCREMENT,
  `generalForumUrl` VARCHAR(300) NOT NULL,
  PRIMARY KEY (`forumID`),
  UNIQUE INDEX `forumID_UNIQUE` (`forumID` ASC) VISIBLE,
  UNIQUE INDEX `generalForumUrl_UNIQUE` (`generalForumUrl` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`promos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`promos` (
  `promoID` INT NOT NULL AUTO_INCREMENT,
  `promoName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`promoID`),
  UNIQUE INDEX `promoID_UNIQUE` (`promoID` ASC) VISIBLE,
  UNIQUE INDEX `promoName_UNIQUE` (`promoName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`game`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`game` (
  `gameID` INT NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(5) NOT NULL,
  `marketUrl` VARCHAR(500) NOT NULL,
  `availability` JSON NOT NULL,
  `filteredAvgRating` DECIMAL(10,2) NOT NULL,
  `overallAvgRating` DECIMAL(10,2) NOT NULL,
  `supportUrl` VARCHAR(300) NOT NULL,
  `gallery` JSON NOT NULL,
  `video` JSON NULL,
  `image` LONGTEXT NOT NULL,
  `boxImage` LONGTEXT NOT NULL,
  `forumID` INT NOT NULL,
  `promoID` INT NULL,
  PRIMARY KEY (`gameID`),
  UNIQUE INDEX `id_UNIQUE` (`gameID` ASC) VISIBLE,
  INDEX `fk_game_generalForum1_idx` (`forumID` ASC) VISIBLE,
  INDEX `fk_game_promos1_idx` (`promoID` ASC) VISIBLE,
  INDEX `idx_game_title` (`title` ASC) VISIBLE,
  INDEX `idx_game_price` (`price` ASC) VISIBLE,
  CONSTRAINT `fk_game_generalForum1`
    FOREIGN KEY (`forumID`)
    REFERENCES `mydb`.`generalForum` (`forumID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_game_promos1`
    FOREIGN KEY (`promoID`)
    REFERENCES `mydb`.`promos` (`promoID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`publisher`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`publisher` (
  `publisherID` INT NOT NULL AUTO_INCREMENT,
  `publisher` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`publisherID`),
  UNIQUE INDEX `publisherID_UNIQUE` (`publisherID` ASC) VISIBLE,
  UNIQUE INDEX `publisher_UNIQUE` (`publisher` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`genres`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`genres` (
  `genreID` INT NOT NULL AUTO_INCREMENT,
  `genre` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`genreID`),
  UNIQUE INDEX `genreID_UNIQUE` (`genreID` ASC) VISIBLE,
  UNIQUE INDEX `genre_UNIQUE` (`genre` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`developer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`developer` (
  `developerID` INT NOT NULL AUTO_INCREMENT,
  `developer` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`developerID`),
  UNIQUE INDEX `developerID_UNIQUE` (`developerID` ASC) VISIBLE,
  UNIQUE INDEX `developer_UNIQUE` (`developer` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`developersGame`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`developersGame` (
  `developerID` INT NOT NULL,
  `gameID` INT NOT NULL,
  PRIMARY KEY (`developerID`, `gameID`),
  INDEX `fk_developer_has_game_game1_idx` (`gameID` ASC) VISIBLE,
  INDEX `fk_developer_has_game_developer1_idx` (`developerID` ASC) VISIBLE,
  CONSTRAINT `fk_developer_has_game_developer1`
    FOREIGN KEY (`developerID`)
    REFERENCES `mydb`.`developer` (`developerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_developer_has_game_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`publishersGame`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`publishersGame` (
  `publisherID` INT NOT NULL,
  `gameID` INT NOT NULL,
  PRIMARY KEY (`publisherID`, `gameID`),
  INDEX `fk_publisher_has_game_game1_idx` (`gameID` ASC) VISIBLE,
  INDEX `fk_publisher_has_game_publisher1_idx` (`publisherID` ASC) VISIBLE,
  CONSTRAINT `fk_publisher_has_game_publisher1`
    FOREIGN KEY (`publisherID`)
    REFERENCES `mydb`.`publisher` (`publisherID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_publisher_has_game_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`whichGenre`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`whichGenre` (
  `gameID` INT NOT NULL,
  `genreID` INT NOT NULL,
  `isPrimaryGenre` TINYINT NOT NULL,
  PRIMARY KEY (`gameID`, `genreID`),
  INDEX `fk_game_genres_has_game_game1_idx` (`gameID` ASC) VISIBLE,
  INDEX `fk_whichGenre_genres1_idx` (`genreID` ASC) VISIBLE,
  CONSTRAINT `fk_game_genres_has_game_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_whichGenre_genres1`
    FOREIGN KEY (`genreID`)
    REFERENCES `mydb`.`genres` (`genreID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`operatingSystem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`operatingSystem` (
  `systemID` INT NOT NULL AUTO_INCREMENT,
  `systemName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`systemID`),
  UNIQUE INDEX `systemID_UNIQUE` (`systemID` ASC) VISIBLE,
  UNIQUE INDEX `systemName_UNIQUE` (`systemName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`whichOperatingSystem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`whichOperatingSystem` (
  `gameID` INT NOT NULL,
  `systemID` INT NOT NULL,
  PRIMARY KEY (`gameID`, `systemID`),
  INDEX `fk_game_has_operatingSystem_operatingSystem1_idx` (`systemID` ASC) VISIBLE,
  INDEX `fk_game_has_operatingSystem_game1_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_game_has_operatingSystem_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_game_has_operatingSystem_operatingSystem1`
    FOREIGN KEY (`systemID`)
    REFERENCES `mydb`.`operatingSystem` (`systemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`integer_col`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`integer_col` (
  `colID` INT NOT NULL AUTO_INCREMENT,
  `colName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`colID`),
  UNIQUE INDEX `col_id_UNIQUE` (`colID` ASC) VISIBLE,
  UNIQUE INDEX `colName_UNIQUE` (`colName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`gamesIntegerCol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`gamesIntegerCol` (
  `gameID` INT NOT NULL,
  `integerColID` INT NOT NULL,
  `integerValue` INT NULL,
  PRIMARY KEY (`gameID`, `integerColID`),
  INDEX `fk_game_has_integer_col_integer_col1_idx` (`integerColID` ASC) VISIBLE,
  INDEX `fk_game_has_integer_col_game1_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_game_has_integer_col_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_game_has_integer_col_integer_col1`
    FOREIGN KEY (`integerColID`)
    REFERENCES `mydb`.`integer_col` (`colID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Boolean_col`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Boolean_col` (
  `colID` INT NOT NULL AUTO_INCREMENT,
  `colName` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`colID`),
  UNIQUE INDEX `colID_UNIQUE` (`colID` ASC) VISIBLE,
  UNIQUE INDEX `colName_UNIQUE` (`colName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`gamesBooleanCol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`gamesBooleanCol` (
  `gameID` INT NOT NULL,
  `booleanColID` INT NOT NULL,
  `booleanValue` TINYINT NOT NULL,
  PRIMARY KEY (`gameID`, `booleanColID`),
  INDEX `fk_game_has_Boolean_col_Boolean_col1_idx` (`booleanColID` ASC) VISIBLE,
  INDEX `fk_game_has_Boolean_col_game1_idx` (`gameID` ASC) VISIBLE,
  CONSTRAINT `fk_game_has_Boolean_col_game1`
    FOREIGN KEY (`gameID`)
    REFERENCES `mydb`.`game` (`gameID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_game_has_Boolean_col_Boolean_col1`
    FOREIGN KEY (`booleanColID`)
    REFERENCES `mydb`.`Boolean_col` (`colID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
