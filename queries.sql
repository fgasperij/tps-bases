-- El listado de inscriptos en cada categoría para el armado de llaves
-- ¿Es necesario devolver los equipos también?
-- TODO: agregar una query separada para los equipos o un group by a esta.
SELECT comp.NumeroCertificadoGraduacion, i.NombreModalidad, cat.IDCategoria
FROM Inscripto i
INNER JOIN SeDivideEn sde on sde.NombreModalidad = i.NombreModalidad
INNER JOIN Categoria cat on cat.IDCategoria = sde.IDCategoria
INNER JOIN Competidor comp on comp.NumeroCertificadoGraduacion = i.NumeroCertificadoGraduacion
WHERE
  ((cat.PesoMaximo is null and cat.PesoMinimo is null)
    or (cat.PesoMaximo is null and comp.Peso >= cat.PesoMinimo)
    or (comp.Peso < cat.PesoMaximo and comp.Peso >= cat.PesoMinimo)
    or (comp.Peso < cat.PesoMaximo and cat.PesoMinimo is null))
  and ((cat.EdadMinima is null and (FLOOR(DATEDIFF(DAY, comp.FechaNacimiento, GETDATE()) / 365.25) < cat.EdadMaxima)
      or ((FLOOR(DATEDIFF(DAY, comp.FechaNacimiento, GETDATE()) / 365.25) >= cat.EdadMinima and FLOOR(DATEDIFF(DAY, comp.FechaNacimiento, GETDATE()) / 365.25) < cat.EdadMaxima)))
  and comp.Sexo = cat.Sexo
  and comp.Graduacion = cat.Graduacion
order by i.NombreModalidad, cat.IDCategoria;


-- El país que obtuvo mayor cantidad de medallas de oro, plata y bronce.

create view EquiposMaestro as
SELECT c.NombreEquipo, min(m.PlacaInstructor) 
FROM Competidor c INNER JOIN m Maestro on m.PlacaInstructor = c.PlacaInstructor
WHERE c.NombreEquipo is not null
GROUP BY c.NombreEquipo;

create view ResultadosMaestro as
	SELECT p.Resultado, em.PlacaInstructor
	FROM (Participacion p INNER JOIN ParticipacionEquipo e on p.IDParticipacion = e.IDParticipacion)
		INNER JOIN EquiposMaestro em on em.NombreEquipo = e.NombreEquipo
	union
	SELECT p.Resultado, m.PlacaInstructor
	FROM ((Participacion p INNER JOIN ParticipacionIndivIDual i on p.IDParticipacion = i.IDParticipacion)
		INNER JOIN Competidor c on i.NumeroCertificadoGraduacion = c.NumeroCertificadoGraduacion)
		INNER JOIN Maestro m on c.PlacaInstructor = m.PlacaInstructor;

create view MaestroMedallas as SELECT * FROM
(SELECT ResultadosMaestro.PlacaInstructor, count(ResultadosMaestro.Resultado) as bronce
	FROM ResultadosMaestro
	WHERE ResultadosMaestro.Resultado = 3
	GROUP BY ResultadosMaestro.PlacaInstructor) as MaestroBronce
INNER JOIN 
(SELECT ResultadosMaestro.PlacaInstructor, count(ResultadosMaestro.Resultado) as plata
	FROM ResultadosMaestro
	WHERE ResultadosMaestro.Resultado = 2
	GROUP BY ResultadosMaestro.PlacaInstructor) as MaestroPlata
on Maestrobronce.PlacaInstructor = MaestroPlata.PlacaInstructor
INNER JOIN
(SELECT ResultadosMaestro.PlacaInstructor, count(ResultadosMaestro.Resultado) as oro
	FROM ResultadosMaestro
	WHERE ResultadosMaestro.Resultado = 1
	GROUP BY ResultadosMaestro.PlacaInstructor) as MaestroOro
on MaestroOro.PlacaInstructor = MaestroPlata.PlacaInstructor;

create view paisMedallas as
SELECT m.NombrePais, sum(MaestroMedallas.bronce) as bronce, sum(MaestroMedallas.plata) as plata, sum(MaestroMedallas.oro) as oro
FROM MaestroMedallas INNER JOIN Maestro on MaestroMedallas.PlacaInstructor = Maestro.PlacaInstructor
	GROUP BY Maestro.NombrePais;

SELECT * FROM paisMedallas
	ORDER BY oro desc
	limit 1
union select * from paisMedallas
	ORDER BY plata desc
	limit 1
union select * from paisMedallas
	ORDER BY bronce desc
	limit 1;

-- El medallero por Escuela.
create view EscuelaMedallas as
SELECT Maestro.Escuela, sum(MaestroMedallas.bronce) as bronce, sum(MaestroMedallas.plata) as plata, sum(MaestroMedallas.oro) as oro
FROM MaestroMedallas INNER JOIN Maestro on MaestroMedallas.PlacaInstructor = Maestro.PlacaInstructor
	GROUP BY Maestro.Escuela;

-- Sabiendo que las medallas de oro suman 3 puntos, las de plata 2 y las de bronce 1
-- punto, se quiere realizar un ranking de puntaje por país y otro por Escuela.

SELECT NombrePais, oro*3 + plata*2 + bronce as puntaje
FROM paisMedallas
ORDER BY puntaje desc;

SELECT Escuela, oro*3 + plata*2 + bronce as puntaje
FROM EscuelaMedallas
ORDER BY puntaje desc;

-- Dado un Competidor, la lista de categorías donde haya participado y el Resultado obtenido.

-- no sé como pasarle un competidor

SELECT p.IDCategoria, p.Resultado
FROM ParticipacionIndividual pi INNER JOIN Participacion p ON p.IDParticipacion = pi.IDParticipacion
WHERE pi.NumeroCertificadoGraduacion = @comp
UNION
SELECT p.IDCategoria, p.Resultado
FROM ParticipacionDeEquipo pe INNER JOIN Participacion p ON p.IDParticipacion = pe.IDParticipacion
	INNER JOIN Competidor c on c.nombreEquipo = pe.nombreEquipo
WHERE c.id = @comp


-- El listado de los árbitros por país.

SELECT *
FROM arbitro
ORDER BY NombrePais desc;

-- La lista de todos los árbitros que actuaron como árbitro central en las modalidades de combate

SELECT a.PlacaArbitro
FROM 
    Arbitraje a INNER JOIN ArbitradoPor ap ON a.IDJurado = ap.IDJurado
WHERE ap.NombreModalidad = 'combate' or ap.NombreModalidad = 'combate por Equipos'
and a.Rol = 'arbitro central';

-- La lista de equipos por país.

SELECT EquiposMaestro.Equipo, Maestro.NombrePais
FROM EquiposMaestro INNER JOIN Maestro on EquiposMaestro.PlacaInstructor = Maestro.PlacaInstructor
ORDER BY Maestro.NombrePais desc;
