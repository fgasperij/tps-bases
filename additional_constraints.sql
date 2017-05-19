-- Restricciones

-- La cantidad de coaches de una escuela debe ser ⅕ de la cantidad de alumnos
drop trigger if exists proporcion_coachs_alumnos;
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
        signal sqlstate '45000' set message_text = 'No se cumple proporcion 20% coaches';
    end if;
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
-- END La graduación va de 1ero a 6to dan.

-- En cada jurado hay:
-- un árbitro con rol “presidente de mesa”
-- un “árbitro central”
-- dos o más “jueces”
-- tres o más “suplentes”.
-- La graduación de cada árbitro debe ser superior a la graduación de las categorías en las que es jurado.
DROP TRIGGER IF EXISTS `validate_jury_before_arbiting`;
DELIMITER $$
CREATE TRIGGER `validate_jury_before_arbiting` BEFORE INSERT ON `ArbitradoPor` FOR EACH ROW
BEGIN
    IF (select cat.Graduacion
        from Categoria cat
        where cat.IDCategoria = NEW.IDCategoria) >
        (select min(a.Graduacion)
            from Arbitraje ar
            INNER JOIN Arbitro a ON ( a.PlacaArbitro = ar.PlacaArbitro)
            where ar.IDJurado = NEW.IDJurado) then
        signal sqlstate '45000' set message_text = 'La graduación del arbitro es menor que la de la categoría';
    END IF;

    IF (select ifnull(count(*), 0) != 1 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = 'Presidente de Mesa') then
        signal sqlstate '45000' set message_text = 'Falta el Presidente de Mesa';
    END IF;

    IF (select ifnull(count(*), 0) != 1 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = 'Arbitro Central') then
        signal sqlstate '45000' set message_text = 'Falta el Arbitro Central';
    END IF;

    IF (select ifnull(count(*), 0) < 2 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = 'Juez') then
        signal sqlstate '45000' set message_text = 'Faltan jueces';
    END IF;

    IF (select ifnull(count(*), 0) < 3 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = 'Suplente') then
        signal sqlstate '45000' set message_text = 'Faltan suplentes';
    END IF;
END;
$$
DELIMITER ;

DROP TRIGGER IF EXISTS `check_jury_insertion`;
DELIMITER $$
CREATE TRIGGER `check_jury_insertion` BEFORE INSERT ON `Arbitraje` FOR EACH ROW
BEGIN
    IF (select ifnull(count(*), 0) > 0 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = NEW.Rol
            and NEW.Rol = 'Presidente de Mesa') then
        signal sqlstate '45000' set message_text = 'Solo puede haber un Presidente de Mesa por jurado';
    END IF;

    IF (select ifnull(count(*), 0) > 0 from Arbitraje a
        where a.IDJurado = NEW.IDJurado
            and a.Rol = NEW.Rol
            and NEW.Rol = 'Arbitro Central') then
        signal sqlstate '45000' set message_text = 'Solo puede haber un Arbitro Central por jurado';
    END IF;
END;
$$
DELIMITER ;

-- El coach de una participación debe ser de la misma escuela que el competidor
-- Los competidores no deben tener Rol ni NombreEquipo ya que se utilizarán SPs específicos para asignárselos.

DROP TRIGGER IF EXISTS `validate_competitor_empty_role_team`;
DELIMITER $$
CREATE TRIGGER `validate_competitor_empty_role_team` BEFORE INSERT ON `Competidor` FOR EACH ROW
BEGIN
    IF (select IF(NombreEquipo is NULL or NombreEquipo = '', false, true) from NEW)
        then
            signal sqlstate '45000' set message_text = 'No deberia tener NombreEquipo durante insercion';
    END IF;

    IF (select IF(RolEquipo is NULL or RolEquipo = '', false, true) from NEW)
        then
            signal sqlstate '45000' set message_text = 'No deberia tener RolEquipo durante insercion';
    END IF;
END;
$$
DELIMITER ;



insert into Categoria values (null, 0, 10, 11, 'Masculino', 50, 60);
insert into Pais value ('Argentina');
insert into Arbitro values (null, 0, 'Esteban Quito', 'Argentina');

insert into Maestro values (null, 'Escuela TK', 'Esteban Quito', 3, 'Argentina');
insert into Maestro values (null, 'Escuela TK', 'Esteban Quito', 8, 'Argentina');

insert into Maestro values (10, 'Escuela TK', 'Esteban Quito', 4, 'Argentina');
insert into Registrado values (null, 'La foto', 10, 'Armando Paredes', 10);

