USE mundial_taekwondo;

DROP PROCEDURE IF EXISTS `agregar_participacion_individual`;

DELIMITER $$
CREATE PROCEDURE `agregar_participacion_individual`(
`Resultado` VARCHAR(45),
`NumeroCertificadoGraduacionCoach` INT,
`NombreModalidad` VARCHAR(45),
`IDCategoria` INT,
`NumeroCertificadoGraduacionCompetidor` INT
) BEGIN
    DECLARE weight_competitor INT;
    DECLARE age_competitor INT;
    DECLARE gender_competitor VARCHAR(45);
    DECLARE graduation_competitor TINYINT(3);
    DECLARE valid boolean DEFAULT false;
    DECLARE last_id_participation INT;
    DECLARE one_participation_per_modality boolean DEFAULT false;


    select c.Peso, TIMESTAMPDIFF(YEAR, c.FechaNacimiento, CURDATE()), c.Sexo, r.Graduacion
            into weight_competitor, age_competitor, gender_competitor, graduation_competitor
                from Competidor c, Registrado r
                where NumeroCertificadoGraduacionCompetidor = c.NumeroCertificadoGraduacion
                    and r.NumeroCertificadoGraduacion = c.NumeroCertificadoGraduacion;

    select if(ifnull(count(*), 0) > 0, false, true) into one_participation_per_modality
        from Participacion p
        inner join ParticipacionIndividual pi on pi.IDParticipacion = p.IDParticipacion
        where p.NombreModalidad = NombreModalidad
            and pi.NumeroCertificadoGraduacionCompetidor = NumeroCertificadoGraduacionCompetidor;

    select  if(ifnull(count(*), 0) > 0, true, false) into valid
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


DROP PROCEDURE IF EXISTS `agregar_participacion_equipo`;

-- Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
-- Los equipos deben tener 5 integrantes cuyo rol sea “titular” y 3 cuyo rol sea “suplente”
-- Todos los integrantes de un equipo deben ser de la misma escuela
-- Todos los integrantes de un equipo deben ser del mismo género, que debe corresponder con el género de la categoría de todas sus participaciones de equipo.
-- Las participaciones de equipo deben ser en la modalidad “combate por equipos”.


DELIMITER $$
CREATE PROCEDURE `agregar_participacion_equipo`(
`arg_name` INT,
) BEGIN

END;


$$
DELIMITER ;