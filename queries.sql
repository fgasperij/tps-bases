-- Inscriptos por categoría para llave

select mcid.ncg, mcid.nombreModalidad, mcid.IDcategoria
    from
        competidor comp,
        (select sde.nombreModalidad, sde.IDcategoria, i.ncg 
            from SeDivideEn sde, inscripto i
            where sde.nombreModalidad = i.nombreModalidad) as mcid,
        categoria cat
    where c.ncg = mcid.ncg
        and cat.IDcategoria = mcid.IDcategoria
        and comp.peso >= cat.pesoMin
        and comp.peso <= cat.pesoMax
        and comp.edad >= cat.edadMin
        and comp.edad <= cat.edadMax
        and comp.genero = cat.genero
        and comp.graduacion = cat.graduacion

-- chequear null
-- devolver equipos en vez de personas?

-- El país que obtuvo mayor cantidad de medallas de oro, plata y bronce.

--set resultadosPais = 
--    (select m.nombrepais, mr.resultado
--       from m maestro,
--        (select p.resultado, c.certificadoGraduacion
--            from (participacionIndividual pi inner join (participaciondeEquipo pe inner join competidor c)), participacion p
--            where (p.tipo = participacionDeEquipo 
--                   and p.idParticipacion = pe.idParticipacion 
--                   and c.nombreEquipo = pe.nombreEquipo)
--                  or (p.tipo = participacionIndividual 
--                      and c.certificadoGraduacion = pi.certificadoGraduacion
--                      and e.certificadoGraduacion = c.certificadoGraduacion) 
--        as cr)
--        where m.placaInstructor = cr.placaInstructor) 
--    as mr)

set resultadosPais =
	select sum(p.resultado), ep.nombrePais
	from (participacion p INNER JOIN participacionEquipo e on p.idParticipacion = e.idParticipacion)
		INNER JOIN equiposPais ep on ep.nombreEquipo = e.nombreEquipo
	where p.resultado <= 3
	group by ep.nombrePais
	union
	select sum(p.resultado), m.nombrePais
	from ((participacion p INNER JOIN participacionIndividual i on p.idParticipacion = i.idParticipacion)
		INNER JOIN competidor c on i.numeroCertificadoGraduacion = c.numeroCertificadoGraduacion)
		INNER JOIN maestro m on c.placaInstructor = m.placaInstructor
	where p.resultado <= 3
	group by m.nombrepais

select sum(resultado), nombrePais
from resultadosPais
group by nombrePais
order by sum(resultado)
limit 1

--select nombrePais, oro, plata, bronce
--    from
--(select nombrePais, sum(case when resultado = 1 then 1 else null end) as oro, sum(case when resultado = 2 then 1 else null end) as plata, sum(case when resultado = 3 then 1 else null end) as bronce
--from resultadosPais
--group by nombrePais)  -- Aca hay algo raro, tiene q ser null o 0 ?


-- falta agarrar el max. Además creo que estoy contando una medalla por integrante de equipo.

-- El medallero por escuela.

set resultadosEscuela = 
(select m.escuela, mr.resultado
    from m maestro,
    (select p.resultado, c.certificadoGraduacion
        from participacionIndividual pi, participaciondeEquipo pe, competidor c, participacion p
        where (p.tipo = participacionDeEquipo 
              and p.idParticipacion = pe.idParticipacion 
              and c.nombreEquipo = pe.nombreEquipo)
            or (p.tipo = participacionIndividual 
                and c.certificadoGraduacion = pi.certificadoGraduacion
                and e.certificadoGraduacion = c.certificadoGraduacion) 
    as cr)
    where m.placaInstructor = cr.placaInstructor) as mr

select escuela, sum(case when resultado = 1 then 1 else null end) as oro, sum(case when resultado = 2 then 1 else null end) as plata, sum(case when resultado = 3 then 1 else null end) as bronce
from resultadosEscuela
group by escuela
order by oro desc

-- Sabiendo que las medallas de oro suman 3 puntos, las de plata 2 y las de bronce 1
-- punto, se quiere realizar un ranking de puntaje por país y otro por escuela.

select nombrePais, sum(case when resultado = 1 then 3 else null end) + sum(case when resultado = 2 then 2 else null end) + sum(case when resultado = 3 then 1 else null end) as puntaje
    from resultadosPais
    group by nombrePais
    order by puntaje desc;

select escuela, sum(case when resultado = 1 then 3 else null end) + sum(case when resultado = 2 then 2 else null end) + sum(case when resultado = 3 then 1 else null end) as puntaje
    from resultadosEscuela
    group by nombreEscuela
    sort by puntaje desc

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
    arbitraje a,
    (select idJurado
    from arbitradoPor
    where nombreModalidad = 'combate' or nombreModalidad = 'combate por equipos') as jm
where a.idJurado = jm.idJurado
and a.rol = 'arbitro central'

-- La lista de equipos por país.

select e.nombreEquipo, m.nombrePais 
from e equipo
	join c competidor
		on e.nombreEquipo = c.nombreEquipo
	join m maestro
		on c.placaInstructor = m.placaInstructor
sort by m.nombrePais desc

--esa creo que repite una vez por competidor, otra:

select c.nombreEquipo, min(m.pais) from 
competidor c
	join m maestro
		on m.placaInstructor = c.placaInstructor
where c.nombreEquipo is not null
group by c.nombreEquipo

--eso sería util para los medalleros si el min no fuera tan trucho
