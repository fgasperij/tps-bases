SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mundial_taekwondo
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mundial_taekwondo
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mundial_taekwondo` DEFAULT CHARACTER SET utf8 ;
USE `mundial_taekwondo` ;

-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Pais`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Pais` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Pais` (
  `NombrePais` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`NombrePais`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Maestro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Maestro` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Maestro` (
  `PlacaInstructor` INT NOT NULL AUTO_INCREMENT,
  `Escuela` VARCHAR(45) NULL,
  `NombreCompleto` VARCHAR(45) NULL,
  `Graduacion` TINYINT(3) NULL,
  `NombrePais` VARCHAR(250) NULL,
  PRIMARY KEY (`PlacaInstructor`),
  INDEX `NombrePais_idx` (`NombrePais` ASC),
  CONSTRAINT `NombrePais`
    FOREIGN KEY (`NombrePais`)
    REFERENCES `mundial_taekwondo`.`Pais` (`NombrePais`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Arbitro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Arbitro` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Arbitro` (
  `PlacaArbitro` INT NOT NULL AUTO_INCREMENT,
  `Graduacion` TINYINT(3) NULL,
  `NombreCompleto` VARCHAR(45) NULL,
  `NombrePais` VARCHAR(250) NULL,
  PRIMARY KEY (`PlacaArbitro`),
  INDEX `NombrePais_idx` (`NombrePais` ASC),
  CONSTRAINT `NombrePaisArbitro`
    FOREIGN KEY (`NombrePais`)
    REFERENCES `mundial_taekwondo`.`Pais` (`NombrePais`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Jurado`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Jurado` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Jurado` (
  `IDJurado` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`IDJurado`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Arbitraje`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Arbitraje` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Arbitraje` (
  `IDJurado` INT NOT NULL,
  `PlacaArbitro` INT NOT NULL,
  `Rol` VARCHAR(45) NULL,
  PRIMARY KEY (`IDJurado`, `PlacaArbitro`),
  INDEX `PlacaArbitro_idx` (`PlacaArbitro` ASC),
  CONSTRAINT `PlacaArbitro`
    FOREIGN KEY (`PlacaArbitro`)
    REFERENCES `mundial_taekwondo`.`Arbitro` (`PlacaArbitro`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `IDJurado`
    FOREIGN KEY (`IDJurado`)
    REFERENCES `mundial_taekwondo`.`Jurado` (`IDJurado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Modalidad`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Modalidad` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Modalidad` (
  `NombreModalidad` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NombreModalidad`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Categoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Categoria` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Categoria` (
  `IDCategoria` INT NOT NULL AUTO_INCREMENT,
  `Graduacion` TINYINT(3) NULL,
  `EdadMinima` INT NULL,
  `EdadMaxima` INT NULL,
  `Sexo` VARCHAR(45) NULL,
  `PesoMinimo` INT NULL,
  `PesoMaximo` INT NULL,
  PRIMARY KEY (`IDCategoria`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`ArbitradoPor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`ArbitradoPor` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`ArbitradoPor` (
  `NombreModalidad` VARCHAR(45) NOT NULL,
  `IDCategoria` INT NOT NULL,
  `IDJurado` INT NULL,
  PRIMARY KEY (`NombreModalidad`, `IDCategoria`),
  INDEX `IDJurado_idx` (`IDJurado` ASC),
  INDEX `IDCategoria_idx` (`IDCategoria` ASC),
  CONSTRAINT `IDJuradoArbitrado`
    FOREIGN KEY (`IDJurado`)
    REFERENCES `mundial_taekwondo`.`Jurado` (`IDJurado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NombreModalidadArbitrado`
    FOREIGN KEY (`NombreModalidad`)
    REFERENCES `mundial_taekwondo`.`Modalidad` (`NombreModalidad`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `IDCategoriaArbitrado`
    FOREIGN KEY (`IDCategoria`)
    REFERENCES `mundial_taekwondo`.`Categoria` (`IDCategoria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`SeDivideEn`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`SeDivideEn` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`SeDivideEn` (
  `IDCategoria` INT NOT NULL,
  `NombreModalidad` VARCHAR(45) NOT NULL,
  `Ring` INT NULL,
  PRIMARY KEY (`IDCategoria`, `NombreModalidad`),
  INDEX `NombreModalidad_idx` (`NombreModalidad` ASC),
  CONSTRAINT `IDCategoria`
    FOREIGN KEY (`IDCategoria`)
    REFERENCES `mundial_taekwondo`.`Categoria` (`IDCategoria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NombreModalidad`
    FOREIGN KEY (`NombreModalidad`)
    REFERENCES `mundial_taekwondo`.`Modalidad` (`NombreModalidad`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Registrado`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Registrado` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Registrado` (
  `NumeroCertificadoGraduacion` INT NOT NULL AUTO_INCREMENT,
  `Foto` BLOB NULL,
  `Graduacion` TINYINT(3) NULL,
  `NombreCompleto` VARCHAR(45) NULL,
  `PlacaInstructor` INT NULL,
  PRIMARY KEY (`NumeroCertificadoGraduacion`),
  INDEX `PlacaInstructor_idx` (`PlacaInstructor` ASC),
  CONSTRAINT `PlacaInstructor`
    FOREIGN KEY (`PlacaInstructor`)
    REFERENCES `mundial_taekwondo`.`Maestro` (`PlacaInstructor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Equipo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Equipo` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Equipo` (
  `NombreEquipo` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`NombreEquipo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Competidor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Competidor` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Competidor` (
  `NumeroCertificadoGraduacion` INT NOT NULL,
  `Peso` INT NULL,
  `DNI` INT NULL,
  `FechaNacimiento` DATE NULL,
  `Sexo` VARCHAR(45) NULL,
  `RolEquipo` VARCHAR(45) NULL,
  `NombreEquipo` VARCHAR(200) NULL,
  PRIMARY KEY (`NumeroCertificadoGraduacion`),
  INDEX `NombreEquipo_idx` (`NombreEquipo` ASC),
  CONSTRAINT `NombreEquipo`
    FOREIGN KEY (`NombreEquipo`)
    REFERENCES `mundial_taekwondo`.`Equipo` (`NombreEquipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NumeroCertificadoGraduacion`
    FOREIGN KEY (`NumeroCertificadoGraduacion`)
    REFERENCES `mundial_taekwondo`.`Registrado` (`NumeroCertificadoGraduacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Coach`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Coach` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Coach` (
  `NumeroCertificadoGraduacion` INT NOT NULL,
  PRIMARY KEY (`NumeroCertificadoGraduacion`),
  CONSTRAINT `NumeroCertificadoGraduacionCoach`
    FOREIGN KEY (`NumeroCertificadoGraduacion`)
    REFERENCES `mundial_taekwondo`.`Registrado` (`NumeroCertificadoGraduacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Inscripto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Inscripto` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Inscripto` (
  `NumeroCertificadoGraduacion` INT NOT NULL,
  `NombreModalidad` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`NumeroCertificadoGraduacion`, `NombreModalidad`),
  CONSTRAINT `NombreModalidadInscripto`
    FOREIGN KEY (`NombreModalidad`)
    REFERENCES `mundial_taekwondo`.`Modalidad` (`NombreModalidad`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NumeroCertificadoGraduacionInscripto`
    FOREIGN KEY (`NumeroCertificadoGraduacion`)
    REFERENCES `mundial_taekwondo`.`Competidor` (`NumeroCertificadoGraduacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`Participacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`Participacion` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`Participacion` (
  `IDParticipacion` INT NOT NULL AUTO_INCREMENT,
  `Resultado` TINYINT(1) NULL,
  `IDCategoria` INT NOT NULL,
  `NombreModalidad` VARCHAR(45) NOT NULL,
  `NumeroCertificadoGraduacionCoach` INT NOT NULL,
  `Tipo` VARCHAR(45) NULL,
  PRIMARY KEY (`IDParticipacion`),
  INDEX `IDCategoria_idx` (`IDCategoria` ASC),
  INDEX `NombreModalidad_idx` (`NombreModalidad` ASC),
  INDEX `NumeroCertificadoGraduacion_idx` (`NumeroCertificadoGraduacionCoach` ASC),
  CONSTRAINT `IDCategoriaParticipacion`
    FOREIGN KEY (`IDCategoria`)
    REFERENCES `mundial_taekwondo`.`Categoria` (`IDCategoria`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NombreModalidadParticipacion`
    FOREIGN KEY (`NombreModalidad`)
    REFERENCES `mundial_taekwondo`.`Modalidad` (`NombreModalidad`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NumeroCertificadoGraduacionParticipacion`
    FOREIGN KEY (`NumeroCertificadoGraduacionCoach`)
    REFERENCES `mundial_taekwondo`.`Coach` (`NumeroCertificadoGraduacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`ParticipacionIndividual`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`ParticipacionIndividual` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`ParticipacionIndividual` (
  `IDParticipacion` INT NOT NULL,
  `NumeroCertificadoGraduacionCompetidor` INT NOT NULL,
  PRIMARY KEY (`IDParticipacion`),
  INDEX `NumeroCertificadoGraduacion_idx` (`NumeroCertificadoGraduacionCompetidor` ASC),
  CONSTRAINT `IDParticipacionIndividual`
    FOREIGN KEY (`IDParticipacion`)
    REFERENCES `mundial_taekwondo`.`Participacion` (`IDParticipacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `NumeroCertificadoGraduacionIndividual`
    FOREIGN KEY (`NumeroCertificadoGraduacionCompetidor`)
    REFERENCES `mundial_taekwondo`.`Competidor` (`NumeroCertificadoGraduacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mundial_taekwondo`.`ParticipacionDeEquipo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mundial_taekwondo`.`ParticipacionDeEquipo` ;

CREATE TABLE IF NOT EXISTS `mundial_taekwondo`.`ParticipacionDeEquipo` (
  `IDParticipacion` INT NOT NULL,
  `NombreEquipo` VARCHAR(200) NULL,
  PRIMARY KEY (`IDParticipacion`),
  INDEX `NombreEquipo_idx` (`NombreEquipo` ASC),
  CONSTRAINT `NombreEquipoEquipo`
    FOREIGN KEY (`NombreEquipo`)
    REFERENCES `mundial_taekwondo`.`Equipo` (`NombreEquipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `IDParticipacionEquipo`
    FOREIGN KEY (`IDParticipacion`)
    REFERENCES `mundial_taekwondo`.`Participacion` (`IDParticipacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
