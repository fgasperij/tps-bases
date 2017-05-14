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





-- En cada jurado hay:
-- un árbitro con rol “presidente de mesa”
-- un “árbitro central”
-- dos o más “jueces”
-- tres o más “suplentes”.
-- La graduación de cada árbitro debe ser superior a la graduación de las categorías en las que es jurado.
-- El coach de una participación debe ser de la misma escuela que el competidor
-- Los competidores no deben tener Rol ni NombreEquipo ya que se utilizarán SPs específicos para asignárselos.