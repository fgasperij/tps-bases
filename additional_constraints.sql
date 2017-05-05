# Restricciones

# La cantidad de coaches de una escuela debe ser ⅕ de la cantidad de alumnos
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

# La graduación va de 1er dan a 6to dan
# Para toda participación:
DELIMITER $$
CREATE TRIGGER validate_participation BEFORE INSERT ON Participacion FOR EACH ROW
BEGIN
    IF NEW.Tipo = "Individual" THEN
        # Si la categoría tiene peso máximo y mínimo el peso del competidor debe estar en el rango
        # Si la categoría tiene edad máxima y mínima la edad del competidor debe estar en el rango
        # Si la categoría tiene género el competidor debe ser de ese género
        # Si la categoría tiene graduación el competidor debe ser de esa graduación
        # Las participaciones individuales no pueden ser en la modalidad “combate por equipos”.
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
        # Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
        # Los equipos deben tener 5 integrantes cuyo rol sea “titular” y 3 cuyo rol sea “suplente”
        # Todos los integrantes de un equipo deben ser de la misma escuela
        # Todos los integrantes de un equipo deben ser del mismo género, que debe corresponder con el género de la categoría de todas sus participaciones de equipo.
        # Las participaciones de equipo deben ser en la modalidad “combate por equipos”.

    END IF;
     -- Use NEW and OLD constants for access to row
END;


$$
DELIMITER ;



# Cada competidor puede tener no puede tener más de una participación por modalidad
# En cada jurado hay:
# un árbitro con rol “presidente de mesa”
# un “árbitro central”
# dos o más “jueces”
# tres o más “suplentes”.
# La graduación de cada árbitro debe ser superior a la graduación de las categorías en las que es jurado.
# El coach de una participación debe ser de la misma escuela que el competidor