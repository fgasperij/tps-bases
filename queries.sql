-- Inscriptos por categoría para llave

select mcid.ncg, mcid.nombreModalidad, mcid.IDcategoria
from
    competidor comp
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

set resultadosPais = 
(select m.nombrepais, mr.resultado
from m maestro,
(select p.resultado, c.certificadoGraduacion
from participacionIndividual pi, participaciondeEquipo pe,  competidor c, participacion p
where (p.tipo = participacionDeEquipo
and p.idParticipacion = pe.idParticipacion
and c.nombreEquipo = pe.nombreEquipo)
or (p.tipo = participacionIndividual
and
c.certificadoGraduacion = pi.certificadoGraduacion
and e.certificadoGraduacion = c.certificadoGraduacion) as cr)
where m.placaInstructor = cr.placaInstructor) as mr

select nombrePais, oro, plata, bronce
from
(select nombrePais, count(resultado = 1) as oro, count(resultado = 2) as plata, count(resultado = 3) as bronce
from resultadosPais
group by nombrePais)
where oro = MAX(oro) or plata = MAX(plata) or bronce = MAX(bronce)

-- esa última línea no sé si anda. Además creo que estoy contando una medalla por integrante de equipo.

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
    and
    c.certificadoGraduacion = pi.certificadoGraduacion
    and e.certificadoGraduacion = c.certificadoGraduacion) as cr)
where m.placaInstructor = cr.placaInstructor) as mr

select escuela, count(resultado = 1) as oro, count(resultado = 2) as plata, count(resultado = 3) as bronce
from resultadosEscuela
group by escuela
order by oro desc

-- Sabiendo que las medallas de oro suman 3 puntos, las de plata 2 y las de bronce 1
punto, se quiere realizar un ranking de puntaje por país y otro por escuela.

select nombrePais, count(resultado = 1) * 3 + count(resultado = 2) *2 + count(resultado = 3) as puntaje
from resultadosPais
group by nombrePais
order by puntaje desc

select escuela, count(resultado = 1) * 3 + count(resultado = 2) *2 + count(resultado = 3) as puntaje
from resultadosEscuela
group by nombreEscuela
sort by puntaje desc

-- Dado un competidor, la lista de categorías donde haya participado y el resultado obtenido.

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
