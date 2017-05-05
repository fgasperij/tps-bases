# Restricciones

# La cantidad de coaches de una escuela debe ser ⅕ de la cantidad de alumnos
DELIMITER $$
CREATE TRIGGER proporcion_coachs_alumnos
    AFTER INSERT ON Competidor
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

# La graduación va de 1er dan a 6to dan
# Para toda participación:
# Si la categoría tiene peso máximo y mínimo el peso del competidor debe estar en el rango
# Si la categoría tiene edad máxima y mínima la edad del competidor debe estar en el rango
# Si la categoría tiene género el competidor debe ser de ese género
# Si la categoría tiene graduación el competidor debe ser de esa graduación
# Todos los integrantes de un equipo deben estar inscriptos en la modalidad combate por equipos
# Los equipos deben tener 5 integrantes cuyo rol sea “titular” y 3 cuyo rol sea “suplente”
# Todos los integrantes de un equipo deben ser de la misma escuela
# Todos los integrantes de un equipo deben ser del mismo género, que debe corresponder con el género de la categoría de todas sus participaciones de equipo.
# Las participaciones de equipo deben ser en la modalidad “combate por equipos”.
# Las participaciones individuales no pueden ser en la modalidad “combate por equipos”.
# Cada competidor puede tener no puede tener más de una participación por modalidad
# En cada jurado hay:
# un árbitro con rol “presidente de mesa”
# un “árbitro central”
# dos o más “jueces”
# tres o más “suplentes”.
# La graduación de cada árbitro debe ser superior a la graduación de las categorías en las que es jurado. 
# El coach de una participación debe ser de la misma escuela que el competidor