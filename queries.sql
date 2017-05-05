-- Inscriptos por categoría para llave

select mcid.ncg, mcid.nombreModalidad, mcid.IDcategoria
    from
        (inscripto i inner join seDivideEn sde on sde.nombreModalidad = i.nombreModalidad)
	inner join categoria cat on cat.IDcategoria = sde.IDcategoria
	inner join competidor comp on comp.numeroCertificadoGraduacion = i.numeroCertificadoGraduacion
    where 
        (cat.pesoMax is null or (comp.peso <= cat.pesoMax and comp.peso >= cat.pesoMin))
        and (cat.edadMin is null or (and (comp.edad >= cat.edadMin and comp.edad <= cat.edadMax)))
        and comp.genero = cat.genero
        and comp.graduacion = cat.graduacion

-- devolver equipos en vez de personas?

-- El país que obtuvo mayor cantidad de medallas de oro, plata y bronce.

set resultadosMaestro =
	select p.resultado, em.numeroPlacaInstructor
	from (participacion p INNER JOIN participacionEquipo e on p.idParticipacion = e.idParticipacion)
		INNER JOIN equiposMaestro em on em.nombreEquipo = e.nombreEquipo
	union
	select p.resultado, m.numeroPlacaInstructor
	from ((participacion p INNER JOIN participacionIndividual i on p.idParticipacion = i.idParticipacion)
		INNER JOIN competidor c on i.numeroCertificadoGraduacion = c.numeroCertificadoGraduacion)
		INNER JOIN maestro m on c.placaInstructor = m.placaInstructor;

set maestroMedallas =
select m.nombrePais from
(select count(resultadosMaestro.resultado) as bronce, resultadosMaestro.placaInstructor
	from resultadosMaestro
	where resultadosMaestro.resultado = 3
	group by resultadosMaestro.placaInstructor) as maestroBronce
inner join 
(select count(resultadosMaestro.resultado) as plata, resultadosMaestro.placaInstructor
	from resultadosPais
	where resultadosMaestro.resultado = 2
	group by resultadosMaestro.placaInstructor) as maestroPlata)
on maestrobronce.nombrePais = maestroPlata.nombrePais
inner join
(select count(resultadosMaestro.resultado) as oro, resultadosMaestro.placaInstructor
	from resultadosPais
	where resultadosMaestro.resultado = 1
	group by resultadosMaestro.placaInstructor) as maestroOro
on paisOro.nombrePais = paisPlata.nombrePais;

set paisMedallas =
select m.nombrePais, sum(maestroMedallas.bronce) as bronce, sum(maestroMedallas.plata) as plata, sum(maestroMedallas.oro) as oro
from maestroMedallas INNER JOIN maestro on maestroMedallas.placaInstructor = maestro.placaInstructor
	group by maestro.nombrePais;

select * from (paisMedallas
	order by oro desc
	limit 1
    union
	paisMedallas
	order by plata desc
	limit 1
    union
	paisMedallas
	maestroMedallas INNER JOIN maestro on maestroMedallas.placaInstructor = maestro.placaInstructor
	order by bronce desc
	limit 1);

-- El medallero por escuela.

select m.escuela, sum(maestroMedallas.bronce) as bronce, sum(maestroMedallas.plata) as plata, sum(maestroMedallas.oro) as oro
from maestroMedallas INNER JOIN maestro on maestroMedallas.placaInstructor = maestro.placaInstructor
	group by maestro.escuela;

-- Sabiendo que las medallas de oro suman 3 puntos, las de plata 2 y las de bronce 1
-- punto, se quiere realizar un ranking de puntaje por país y otro por escuela.

select nombrePais, oro*3 + plata*2 + bronce as puntaje
from paisMedallas
order by puntaje desc;

select escuela, oro*3 + plata*2 + bronce as puntaje
from escuelaMedallas
order by puntaje desc;

-- Dado un competidor, la lista de categorías donde haya participado y el resultado obtenido.

create procedure getCategories
@comp varchar(25)
as
select 
from 
where competidor = @comp;
Go

-- no sé como pasarle un competidor

select IDCategoria, resultado
from participacion

-- El listado de los árbitros por país.

select *
from arbitro
sort by nombrePais desc

-- La lista de todos los árbitros que actuaron como árbitro central en las modalidades de combate

select a.placaArbitro
from 
    arbitraje a INNER JOIN arbitradoPor ap ON a.idJurado = ap.idJurado
where ap.nombreModalidad = 'combate' or ap.nombreModalidad = 'combate por equipos'
and a.rol = 'arbitro central'

-- La lista de equipos por país.

set equiposMaestro =

select c.nombreEquipo, min(m.placaInstructor) 
from competidor c inner join m maestro on m.placaInstructor = c.placaInstructor
where c.nombreEquipo is not null
group by c.nombreEquipo; --reusado más arriba

select equiposMaestro.equipo, maestro.nombrePais
from equiposMaestro INNER JOIN maestro on equiposMaestro.placaInstructor = maestro.placaInstructor
order by maestro.nombrePais desc
