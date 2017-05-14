USE mundial_taekwondo;

DROP PROCEDURE IF EXISTS `agregar_participacion_individual`;

DELIMITER $$
CREATE PROCEDURE `agregar_participacion_individual`(
`Resultado` VARCHAR(45),
`NumeroCertificadoGraduacionCoach` INT,
`NombreModalidad` VARCHAR(45),
`IDCategoria` INT,
`NumeroCertificadoGraduacionCompetidor` INT
)
BEGIN
    DECLARE weight_competitor INT;
    DECLARE age_competitor INT;
    DECLARE gender_competitor VARCHAR(45);
    DECLARE graduation_competitor TINYINT(3);
    DECLARE valid boolean DEFAULT false;
    DECLARE last_id_participation INT;
    DECLARE one_participation_per_modality boolean DEFAULT false;

    IF (select ifnull(count(*), 0) = 0
            from Inscripto i
            where i.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor
                and i.NombreModalidad = NombreModalidad) then
        signal sqlstate '45000' set message_text = 'No esta inscripto en la modalidad';
    END IF;

    select c.Peso, TIMESTAMPDIFF(YEAR, c.FechaNacimiento, CURDATE()), c.Sexo, r.Graduacion
            into weight_competitor, age_competitor, gender_competitor, graduation_competitor
                from Competidor c, Registrado r
                where NumeroCertificadoGraduacionCompetidor = c.NumeroCertificadoGraduacion
                    and r.NumeroCertificadoGraduacion = c.NumeroCertificadoGraduacion;

    select ifnull(count(*), 0) = 0 into one_participation_per_modality
        from Participacion p
        inner join ParticipacionIndividual pi on pi.IDParticipacion = p.IDParticipacion
        where p.NombreModalidad = NombreModalidad
            and pi.NumeroCertificadoGraduacionCompetidor = NumeroCertificadoGraduacionCompetidor;

    select  ifnull(count(*), 0) > 0 into valid
            from Categoria c
            where IDCategoria = c.IDCategoria
                and c.Graduacion = graduation_competitor
                and c.Sexo = gender_competitor
                and c.PesoMaximo >= weight_competitor
                and c.PesoMinimo <= weight_competitor
                and c.EdadMaxima >= age_competitor
                and c.EdadMinima <= age_competitor
                and NombreModalidad <> "Equipo"
                and NumeroCertificadoGraduacionCoach in (select NumeroCertificadoGraduacion from Coach);

    IF (valid = true and one_participation_per_modality = true) then
        INSERT INTO `Participacion`(
            `IDParticipacion`,
            `Resultado`,
            `IDCategoria`,
            `NombreModalidad`,
            `NumeroCertificadoGraduacionCoach`,
            `Tipo`
        )
        VALUES(
            NULL, -- para crear nuevo id
            Resultado,
            IDCategoria,
            NombreModalidad,
            NumeroCertificadoGraduacionCoach,
            'Individual'
        );
        select LAST_INSERT_ID() into last_id_participation;
        INSERT INTO `ParticipacionIndividual`(
            `IDParticipacion`,
            `NumeroCertificadoGraduacionCompetidor`
        )
        VALUES(
            last_id_participation,
            NumeroCertificadoGraduacionCompetidor
        );
    ELSE
        signal sqlstate '45000' set message_text = 'Combinacion de parametros invalida';
    END IF;

END;

$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `create_team`;
DELIMITER $$
CREATE PROCEDURE `create_team`(
`NombreEquipo` VARCHAR(200)
)
BEGIN
  IF (select ifnull(count(*), 0) = 0
        from Equipo e
        where NombreEquipo = e.NombreEquipo) then
    insert into Equipo(NombreEquipo) VALUES(NombreEquipo);
  ELSE
    signal sqlstate '45000' set message_text = 'Equipo ya existe';
  END IF;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `add_to_team`;
DELIMITER $$
CREATE PROCEDURE `add_to_team`(
`NumeroCertificadoGraduacionCompetidor` INT,
`RolEquipo` VARCHAR(45),
`NombreEquipo` VARCHAR(200)
)
BEGIN
    DECLARE gender_team VARCHAR(45);
    DECLARE team_school VARCHAR(45);
    DECLARE competitor_school VARCHAR(45);

    IF (select ifnull(count(*), 0) = 8
            from Competidor c
            where c.NombreEquipo = NombreEquipo)
        then
            signal sqlstate '45000' set message_text = 'Equipo lleno';
    END IF;

    IF (select ifnull(count(*), 0) = 3
            from Competidor c
            where c.NombreEquipo = NombreEquipo
            and RolEquipo = 'Suplente'
            and RolEquipo = c.RolEquipo)
        then
            signal sqlstate '45000' set message_text = 'Suplentes llenos';
    END IF;

    IF (select ifnull(count(*), 0) = 5
            from Competidor c
            where c.NombreEquipo = NombreEquipo
            and RolEquipo = 'Titular'
            and RolEquipo = c.RolEquipo)
        then
            signal sqlstate '45000' set message_text = 'Titulares llenos';
    END IF;

    IF (select ifnull(count(*), 0) = 0
            from Competidor c
            where c.NombreEquipo = NombreEquipo) then
        set gender_team = (select co.Sexo from Competidor co
                            where co.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor);

    ELSE
        set gender_team = (select c.Sexo from Competidor C
                            where c.NombreEquipo = NombreEquipo
                            group by c.Sexo);
    END IF;

    IF (select co.Sexo <> gender_team from Competidor co
            where co.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor)
        then
            signal sqlstate '45000' set message_text = 'Sexo invalido';
    END IF;

    IF (select IF(c.NombreEquipo is NULL or c.NombreEquipo = '', false, true)
         from Competidor c
         where c.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor)
        then
            signal sqlstate '45000' set message_text = 'Ya tiene equipo';
    END IF;

    IF (select IF(c.RolEquipo is NULL or c.RolEquipo = '', false, true)
         from Competidor c
         where c.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor)
        then
            signal sqlstate '45000' set message_text = 'Ya tiene rol';
    END IF;

-- Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
   IF (select ifnull(count(*), 0) = 0
            from Inscripto i
            where i.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor
                and i.NombreModalidad = 'Combate por Equipos') then
        signal sqlstate '45000' set message_text = 'No esta inscripto en la modalidad Combate por Equipos';
    END IF;

-- Todos los integrantes de un equipo deben ser de la misma escuela

    (select ifnull(m.Escuela, '') into team_school
            from Competidor C
            inner join Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
            inner join Maestro m on r.PlacaInstructor = m.PlacaInstructor
            where c.NombreEquipo = NombreEquipo
            group by m.Escuela);

    (select m.Escuela into competitor_school
        from Competidor C
        inner join Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
        inner join Maestro m on r.PlacaInstructor = m.PlacaInstructor
        where c.NumeroCertificadoGraduacion = NumeroCertificadoGraduacionCompetidor);

    IF (team_school <> '' and team_school <> competitor_school) then
        signal sqlstate '45000' set message_text = 'Diferentes escuelas';
    END IF;


    UPDATE `Competidor` SET
      `Competidor.NombreEquipo` = NombreEquipo,
      `Competidor.RolEquipo` = RolEquipo
    WHERE `Competidor.NumeroCertificadoGraduacion` = NumeroCertificadoGraduacionCompetidor;
END;
$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `agregar_participacion_equipo`;

-- Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
-- Los equipos deben tener 5 integrantes cuyo rol sea “titular” y 3 cuyo rol sea “suplente”
-- Todos los integrantes de un equipo deben ser de la misma escuela
-- Todos los integrantes de un equipo deben ser del mismo género, que debe corresponder con el género de la categoría de todas sus participaciones de equipo.
-- Las participaciones de equipo deben ser en la modalidad “combate por equipos”.

DELIMITER $$
CREATE PROCEDURE `agregar_participacion_equipo`(
`NombreEquipo` VARCHAR(200),

) BEGIN

END;


$$
DELIMITER ;