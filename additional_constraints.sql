-- Restricciones

-- La cantidad de coaches de una escuela debe ser ⅕ de la cantidad de alumnos
DELIMITER $$
CREATE TRIGGER proporcion_coachs_alumnos
    BEFORE INSERT ON Competidor
    FOR EACH ROW
BEGIN
	declare competidores int;
    declare coaches int;
    declare placa_instructor_del_nuevo_competidor int;
    set placa_instructor_del_nuevo_competidor = (select r.PlacaInstructor
                                                 from Competidor c
                                                 inner join Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
                                                 where c.NumeroCertificadoGraduacion = NEW.NumeroCertificadoGraduacion);
    set competidores = (select count(*)
                        from Competidor c
                        inner join Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
                        where r.PlacaInstructor = placa_instructor_del_nuevo_competidor);
    set coaches = (select count(*)
                   from Competidor c
                   inner join Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
                   where r.PlacaInstructor = placa_instructor_del_nuevo_competidor);
	if competidores > coaches * 5
    then

END$$
DELIMITER ;

-- La graduación va de 1er dan a 6to dan

-- Maestro
drop trigger if exists graduacion_maestro_va_de_1_a_6;
DELIMITER $$
CREATE TRIGGER graduacion_maestro_va_de_1_a_6
    BEFORE INSERT ON Maestro
    FOR EACH ROW
BEGIN
    if NEW.Graduacion < 0 or NEW.Graduacion > 6
    then
        signal sqlstate '45000' set message_text = 'La graduación está fuera del rango válido. Debe ser entre 1ero y 6to dan.';
    end if;
END$$
DELIMITER ;

insert into Pais value ('Argentina');
insert into Maestro values (null, 'Escuela TK', 'Esteban Quito', 3, 'Argentina');
insert into Maestro values (null, 'Escuela TK', 'Esteban Quito', 8, 'Argentina');


-- Árbitro
drop trigger if exists graduacion_arbitro_va_de_1_a_6;
DELIMITER $$
CREATE TRIGGER graduacion_arbitro_va_de_1_a_6
    BEFORE INSERT ON Arbitro
    FOR EACH ROW
BEGIN
    if NEW.Graduacion < 1 or NEW.Graduacion > 6
    then
        signal sqlstate '45000' set message_text = 'La graduación está fuera del rango válido. Debe ser entre 1ero y 6to dan.';
    end if;
END$$
DELIMITER ;

insert into Pais value ('Argentina');
insert into Arbitro values (null, 0, 'Esteban Quito', 'Argentina');

-- Categoría
drop trigger if exists graduacion_categoria_va_de_1_a_6;
DELIMITER $$
CREATE TRIGGER graduacion_categoria_va_de_1_a_6
    BEFORE INSERT ON Categoria
    FOR EACH ROW
BEGIN
    if NEW.Graduacion < 1 or NEW.Graduacion > 6
    then
        signal sqlstate '45000' set message_text = 'La graduación está fuera del rango válido. Debe ser entre 1ero y 6to dan.';
    end if;
END$$
DELIMITER ;

insert into Categoria values (null, 0, 10, 11, 'Masculino', 50, 60);

-- Registrado
drop trigger if exists graduacion_registrado_va_de_1_a_6;
DELIMITER $$
CREATE TRIGGER graduacion_registrado_va_de_1_a_6
    BEFORE INSERT ON Registrado
    FOR EACH ROW
BEGIN
    if NEW.Graduacion < 1 or NEW.Graduacion > 6
    then
        signal sqlstate '45000' set message_text = 'La graduación está fuera del rango válido. Debe ser entre 1ero y 6to dan.';
    end if;
END$$
DELIMITER ;

insert into Maestro values (10, 'Escuela TK', 'Esteban Quito', 4, 'Argentina');
insert into Registrado values (null, 'La foto', 10, 'Armando Paredes', 10);

-- END La graduación va de 1ero a 6to dan.



-- Para toda participación:

DELIMITER $$
CREATE TRIGGER validate_participation BEFORE INSERT ON Participacion FOR EACH ROW
BEGIN
    IF NEW.Tipo = "Individual" THEN
        -- Si la categoría tiene peso máximo y mínimo el peso del competidor debe estar en el rango
        -- Si la categoría tiene edad máxima y mínima la edad del competidor debe estar en el rango
        -- Si la categoría tiene género el competidor debe ser de ese género
        -- Si la categoría tiene graduación el competidor debe ser de esa graduación
        -- Las participaciones individuales no pueden ser en la modalidad “combate por equipos”.
        DECLARE weight_competitor INT;
        DECLARE age_competitor INT;
        DECLARE gender_competitor VARCHAR(45);
        DECLARE graduation_competitor TINYINT(3);
        DECLARE valid boolean DEFAULT false;

        select c.Peso, c.Edad, c.Sexo, r.Graduacion into weight_competitor, age_competitor, gender_competitor, graduation_competitor
                from ParticipacionIndividual i, Competidor c, Registrado r
                where NEW.IDParticipacion = i.IDParticipacion
                    and i.NumeroCertificadoGraduacionCompetidor = c.NumeroCertificadoGraduacion
                    and r.NumeroCertificadoGraduacion = c.NumeroCertificadoGraduacion;

        select  if (ifnull(count(*), 0) > 0, true, false) into valid
            from Categoria c, SeDivideEn
            where NEW.IDCategoria = c.IDCategoria
                and c.Graduacion = graduation_competitor
                and c.Sexo = gender_competitor
                and c.PesoMaximo >= weight_competitor
                and c.PesoMinimo <= weight_competitor
                and c.EdadMaxima >= age_competitor
                and c.EdadMinima <= age_competitor
                and NEW.NombreModalidad <> "Equipo";

        IF valid = false then
            rollback transaction
        END IF;

    ELSE
        -- Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
        -- Los equipos deben tener 5 integrantes cuyo rol sea “titular” y 3 cuyo rol sea “suplente”
        -- Todos los integrantes de un equipo deben ser de la misma escuela
        -- Todos los integrantes de un equipo deben ser del mismo género, que debe corresponder con el género de la categoría de todas sus participaciones de equipo.
        -- Las participaciones de equipo deben ser en la modalidad “combate por equipos”.

    END IF;
     -- Use NEW and OLD constants for access to row
END;


$$
DELIMITER ;



-- En cada jurado hay:
-- un árbitro con rol “presidente de mesa”
-- un “árbitro central”
-- dos o más “jueces”
-- tres o más “suplentes”.
-- La graduación de cada árbitro debe ser superior a la graduación de las categorías en las que es jurado.
-- El coach de una participación debe ser de la misma escuela que el competidor