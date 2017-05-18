-- El listado de inscriptos en cada categoría para el armado de llaves

SELECT comp.NumeroCertificadoGraduacion, i.NombreModalidad, cat.IDCategoria
FROM Inscripto i
INNER JOIN SeDivideEn sde on sde.NombreModalidad = i.NombreModalidad
INNER JOIN Categoria cat on cat.IDCategoria = sde.IDCategoria
INNER JOIN Competidor comp on comp.NumeroCertificadoGraduacion = i.NumeroCertificadoGraduacion
INNER JOIN Registrado r on r.NumeroCertificadoGraduacion = i.NumeroCertificadoGraduacion
WHERE
  ((cat.PesoMaximo is null and cat.PesoMinimo is null)
    or (cat.PesoMaximo is null and comp.Peso >= cat.PesoMinimo)
    or (comp.Peso < cat.PesoMaximo and comp.Peso >= cat.PesoMinimo)
    or (comp.Peso < cat.PesoMaximo and cat.PesoMinimo is null))
    and ((cat.EdadMinima is null and (FLOOR(DATEDIFF(NOW(), comp.FechaNacimiento) / 365.25) < cat.EdadMaxima)
      or ((FLOOR(DATEDIFF(NOW(), comp.FechaNacimiento) / 365.25) >= cat.EdadMinima and FLOOR(DATEDIFF(NOW(), comp.FechaNacimiento) / 365.25) < cat.EdadMaxima)))
  and comp.Sexo = cat.Sexo
  and (cat.Graduacion is null or r.Graduacion = cat.Graduacion)
  and i.NombreModalidad != 'Combate por Equipos')
order by i.NombreModalidad, cat.IDCategoria;

-- Equipos por categoria

SELECT comp.NombreEquipo, min(Inscripto.NombreModalidad), min(Categoria.IDCategoria)
FROM Inscripto i
INNER JOIN SeDivideEn sde on sde.NombreModalidad = i.NombreModalidad
INNER JOIN Categoria cat on cat.IDCategoria = sde.IDCategoria
INNER JOIN Competidor comp on comp.NumeroCertificadoGraduacion = i.NumeroCertificadoGraduacion
INNER JOIN Registrado r on r.NumeroCertificadoGraduacion = i.NumeroCertificadoGraduacion
WHERE
  comp.Sexo = cat.Sexo
  and (cat.Graduacion is null or r.Graduacion = cat.Graduacion)
  and comp.NombreEquipo is not null
  and i.NombreModalidad != 'Combate por Equipos'
group by comp.NombreEquipo
order by cat.IDCategoria;

-- El país que obtuvo mayor cantidad de medallas de oro, plata y bronce.

create or replace view EquiposMaestro as
SELECT c.NombreEquipo, min(m.PlacaInstructor) as PlacaInstructor
FROM Competidor c
	INNER JOIN Registrado r on c.NumeroCertificadoGraduacion = r.NumeroCertificadoGraduacion
	INNER JOIN Maestro m on m.PlacaInstructor = r.PlacaInstructor
WHERE c.NombreEquipo is not null
GROUP BY c.NombreEquipo;

create or replace view ResultadosMaestro as
	SELECT p.Resultado, em.PlacaInstructor
	FROM (Participacion p INNER JOIN ParticipacionDeEquipo e on p.IDParticipacion = e.IDParticipacion)
		INNER JOIN EquiposMaestro em on em.NombreEquipo = e.NombreEquipo
	union
	SELECT p.Resultado, m.PlacaInstructor
	FROM ((Participacion p INNER JOIN ParticipacionIndividual i on p.IDParticipacion = i.IDParticipacion)
		INNER JOIN Registrado r on i.NumeroCertificadoGraduacionCompetidor = r.NumeroCertificadoGraduacion)
		INNER JOIN Maestro m on r.PlacaInstructor = m.PlacaInstructor;

create or replace view MaestroMedallas as
SELECT ResultadosMaestro.PlacaInstructor, 
	sum(CASE WHEN ResultadosMaestro.Resultado = 3 THEN 1 ELSE 0 END) as bronce,
	sum(CASE WHEN ResultadosMaestro.Resultado = 2 THEN 1 ELSE 0 END) as plata,
	sum(CASE WHEN ResultadosMaestro.Resultado = 1 THEN 1 ELSE 0 END) as oro
	FROM ResultadosMaestro;

create or replace view paisMedallas as
SELECT m.NombrePais, sum(MaestroMedallas.bronce) as bronce, sum(MaestroMedallas.plata) as plata, sum(MaestroMedallas.oro) as oro
FROM MaestroMedallas INNER JOIN Maestro on MaestroMedallas.PlacaInstructor = Maestro.PlacaInstructor
	GROUP BY Maestro.NombrePais;

SELECT * FROM paisMedallas
	where oro = (select max(oro) from paisMedallas)
union
SELECT * FROM paisMedallas
	where plata = (select max(plata) from paisMedallas)
union
SELECT * FROM paisMedallas
	where bronce = (select max(bronce) from paisMedallas);

-- El medallero por Escuela.
create or replace view EscuelaMedallas as
SELECT Maestro.Escuela, sum(MaestroMedallas.bronce) as bronce, sum(MaestroMedallas.plata) as plata, sum(MaestroMedallas.oro) as oro
FROM MaestroMedallas INNER JOIN Maestro on MaestroMedallas.PlacaInstructor = Maestro.PlacaInstructor
	GROUP BY Maestro.Escuela;

select * from EscuelaMedallas

-- Sabiendo que las medallas de oro suman 3 puntos, las de plata 2 y las de bronce 1
-- punto, se quiere realizar un ranking de puntaje por país y otro por Escuela.

SELECT NombrePais, oro*3 + plata*2 + bronce as puntaje
FROM paisMedallas
ORDER BY puntaje desc;

SELECT Escuela, oro*3 + plata*2 + bronce as puntaje
FROM EscuelaMedallas
ORDER BY puntaje desc;

-- Dado un Competidor, la lista de categorías donde haya participado y el Resultado obtenido.

DROP PROCEDURE IF EXISTS `participaciones_competidor`;
DELIMITER $$
CREATE PROCEDURE `participaciones_competidor`(
`NumeroCertificadoGraduacion` INT
) BEGIN
    SELECT p.IDCategoria, p.Resultado
    FROM ParticipacionIndividual pi INNER JOIN Participacion p ON p.IDParticipacion = pi.IDParticipacion
    WHERE pi.NumeroCertificadoGraduacionCompetidor = NumeroCertificadoGraduacion
    UNION
    SELECT p.IDCategoria, p.Resultado
    FROM ParticipacionDeEquipo pe INNER JOIN Participacion p ON p.IDParticipacion = pe.IDParticipacion
        INNER JOIN Competidor c on c.nombreEquipo = pe.nombreEquipo
    WHERE c.NumeroCertificadoGraduacionCompetidor = NumeroCertificadoGraduacion;
END;
$$
DELIMITER ;


-- El listado de los árbitros por país.

SELECT *
FROM Arbitro
ORDER BY NombrePais desc;

-- La lista de todos los árbitros que actuaron como árbitro central en las modalidades de combate

SELECT a.PlacaArbitro
FROM
    Arbitraje a INNER JOIN ArbitradoPor ap ON a.IDJurado = ap.IDJurado
WHERE (ap.NombreModalidad = 'Combate' or ap.NombreModalidad = 'Combate por Equipos')
and a.Rol = 'arbitro central';

-- La lista de equipos por país.

SELECT EquiposMaestro.NombreEquipo, Maestro.NombrePais
FROM EquiposMaestro INNER JOIN Maestro on EquiposMaestro.PlacaInstructor = Maestro.PlacaInstructor
ORDER BY Maestro.NombrePais desc;
